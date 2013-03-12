child_process = require 'child_process'
fs = require 'fs'

mkdirp = require 'mkdirp'
request = require 'request'
sinon = require 'sinon'
should = require 'should'
_ = require 'underscore'

class Model
  constructor: (obj) ->
    for k of obj
      @[k] = obj[k]
  toObject: -> @

class MockDb
  save: (callback) ->
    callback null

class TestDb extends MockDb
  @find: (_args, callback) ->
    callback null, [ new Model(name: 'dataset-tool', type: 'importer'),
      new Model(name: 'view-tool', type: 'view')
    ]
  # Only works when searching for name properties.
  @findOne: (args, callback) ->
    @find {}, (err, all) ->
      callback null, _.findWhere all, name: args.name

class DatasetDb extends MockDb
  @find: (args, callback) ->
    callback null, [
      new Model
        name: 'dataset1'
        tool: 'dataset-tool'
        box: 'ds-box'
        views: [ new Model(name: 'view1', tool: 'view-tool', box: 'view-box') ]
      ]

class UserDb extends MockDb
  @findOne: (args, callback) ->
    callback null, new Model
      name: 'testington'
      apikey: process.env.COTEST_USER_API_KEY
      displayName: 'Lord Test Testington'

Tool = require('model/tool')(TestDb)
Dataset = require('model/dataset').dbInject DatasetDb
User = require('model/user').dbInject UserDb

describe 'Server model: Tool', ->

  before ->
    @saveSpy = sinon.spy MockDb.prototype, 'save'
    @findSpy = sinon.spy TestDb, 'find'
    @tool = new Tool name: 'dataset-tool'
    mkdirp.sync 'test/tmp/repos'

  context 'when tool.save is called', ->
    before (done) ->
      @tool.save done

    it 'calls mongoose save method', ->
      @saveSpy.calledOnce.should.be.true

  context 'when tool.findAll is called', ->
    before (done) ->
      Tool.findAll (err, res) =>
        @results = res
        done()

    it 'should return Tool results', ->
      @results[0].should.be.an.instanceOf Tool
      @results[0].name.should.equal 'dataset-tool'
      @results.length.should.equal 2

  context 'when loading from git', ->
    before ->
      @exec = sinon.stub child_process, 'exec', (child, cb) -> cb()

    context 'if tool is new', ->
      before (done) ->
        @fsExists = sinon.stub fs, 'exists', (path_, cb) ->
          cb false
        @tool = new Tool name: 'test'
        @tool.gitCloneOrPull dir: "test/tmp/repos", done

      it 'should git clone a directory', ->
        @exec.calledWithMatch(/^git clone/).should.be.true

      before (done) ->
        @spy = sinon.spy JSON, 'parse'
        fs.exists.restore()
        @fsExists = sinon.stub fs, 'exists', (path_, cb) ->
          cb true
        @fsRead = sinon.stub fs, 'readFile', (path_, cb) ->
          obj =
            displayName: 'WHEEEE'
            description: 'Whee whee whee'
            gitUrl: 'git://blah.git'
          cb null, JSON.stringify obj
        @tool.loadManifest done

      after ->
        JSON.parse.restore()
        fs.exists.restore()
        fs.readFile.restore()

      it 'tool.loadManifest should parse the json file', ->
        @fsRead.calledOnce.should.be.true
        @spy.calledOnce.should.be.true

      it 'should have a displayName', ->
        should.exist @tool.manifest.displayName

      it 'should have a description', ->
        should.exist @tool.manifest.description

      it 'should have a gitUrl', ->
        should.exist @tool.manifest.gitUrl

    context 'if tool already exists', ->
      before (done) ->
        @spy = sinon.spy JSON, 'parse'
        @fsExists = sinon.stub fs, 'exists', (path_, cb) ->
          cb true
        @tool = new Tool name: 'test'
        @tool.gitCloneOrPull dir: "test/tmp/repos", done

      it 'should run a git pull', ->
        @exec.calledWithMatch(/git pull/).should.be.true

      before (done) ->
        @fsRead = sinon.stub fs, 'readFile', (path_, cb) ->
          obj =
            displayName: 'SQUEEE'
            description: 'Squee squee squee'
            gitUrl: 'git://rah.git'
          cb null, JSON.stringify obj
        @tool.loadManifest done

      after ->
        JSON.parse.restore()
        fs.exists.restore()
        fs.readFile.restore()

      it 'tool.loadManifest should parse the json file', ->
        @fsRead.calledOnce.should.be.true
        @spy.calledOnce.should.be.true

      it 'should have a displayName', ->
        should.exist @tool.manifest.displayName

      it 'should have a description', ->
        should.exist @tool.manifest.description
        
      it 'should have a gitUrl', ->
        should.exist @tool.manifest.gitUrl

  context 'when tool.updateInstances is called', ->
    before (done) ->
      @requestStub = sinon.stub(request, 'post').callsArg(1)
      Tool.findOneByName 'dataset-tool', (err, tool) =>
        tool.updateInstances ->
          Tool.findOneByName 'view-tool', (err, tool) =>
            tool.updateInstances done

    it 'has updated the dataset boxes', ->
      pulledInDSBox = @requestStub.calledWithMatch
        uri: sinon.match /ds-box/
        form:
          apikey: sinon.match new RegExp(process.env.COTEST_USER_API_KEY)
          cmd: sinon.match /git pull/
      pulledInDSBox.should.be.true

    it 'has updated the view boxes', ->
      pulledInViewBox = @requestStub.calledWithMatch
        uri: sinon.match /view-box/
        form:
          apikey: sinon.match new RegExp(process.env.COTEST_USER_API_KEY)
          cmd: sinon.match /git pull/
      pulledInViewBox.should.be.true

    after ->
      request.post.restore()
