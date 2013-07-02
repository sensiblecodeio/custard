mongoose = require 'mongoose'
child_process = require 'child_process'
fs = require 'fs'

mkdirp = require 'mkdirp'
request = require 'request'
sinon = require 'sinon'
should = require 'should'
_ = require 'underscore'

{Tool} = require 'model/tool'

describe 'Server model: Tool', ->

  before ->
    mongoose.connect process.env.CU_DB unless mongoose.connection.db

  before ->
    @tool = new Tool
      name: 'dataset-tool'
      type: 'importer'
    mkdirp.sync 'test/tmp/repos'

  before (done) ->
    @tool.save done

  context 'when tool.findAll is called', ->
    before (done) ->
      Tool.findAll (err, res) =>
        @results = res
        done()

    it 'should return at least one tool', ->
      our_tool = _.find @results, (result) ->
        result.name is 'dataset-tool'
      should.exist our_tool
      our_tool.should.be.an.instanceOf Tool
      our_tool.name.should.equal 'dataset-tool'

  context 'when loading from git', ->
    before ->
      @exec = sinon.stub child_process, 'exec', (child, cb) -> cb()

    after ->
      child_process.exec.restore()

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

  context 'An "importer" tool: when tool.updateInstances is called', ->
    before (done) ->
      @requestStub = sinon.stub(request, 'post').callsArg(1)
      Tool.findOneByName 'spreadsheet-upload', (err, tool) =>
        tool.updateInstances done

    it 'has updated the dataset boxes', ->
      pulledInDSBox = @requestStub.calledWith
        uri: sinon.match /2416349265/
        form:
          apikey: 'zarino'
          cmd: sinon.match /git pull/
      pulledInDSBox.should.be.true

    after ->
      request.post.restore()

  xcontext 'A "view" tool: when tool.updateInstances is called', ->
    before (done) ->
      @requestStub = sinon.stub(request, 'post').callsArg(1)
      Tool.findOneByName 'test-plugin', (err, tool) =>
        tool.updateInstances done

    it 'has updated the view boxes', ->
      pulledInViewBox = @requestStub.calledWithMatch
        uri: sinon.match /4008115731/
        form:
          apikey: sinon.match new RegExp(process.env.COTEST_USER_API_KEY)
          cmd: sinon.match /git pull/
      pulledInViewBox.should.be.true

    after ->
      request.post.restore()
