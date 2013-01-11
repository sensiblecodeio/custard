child_process = require 'child_process'
fs = require 'fs'

mkdirp = require 'mkdirp'
sinon = require 'sinon'
should = require 'should'

class TestDb
  class Model
    constructor: (obj) ->
      for k of obj
        @[k] = obj[k]

    toObject: -> @

  save: (callback) ->
    callback null
  @find: (_args, callback) ->
    callback null, [ new Model(name: 'test'),
      new Model(name: 'test2')
    ]

Tool = require('model/tool')(TestDb)

describe 'Server model: Tool', ->

  before ->
    @saveSpy = sinon.spy TestDb.prototype, 'save'
    @findSpy = sinon.spy TestDb, 'find'
    @tool = new Tool name: 'test'
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
      @results[0].name.should.equal 'test'
      @results.length.should.equal 2
   
    context 'when loading from git', ->
      before (done) ->
        @exec = sinon.stub child_process, 'exec', (child, cb) -> cb()
        @tool = new Tool name: 'test'
        @tool.gitClone dir: "test/tmp/repos", done
 
      it 'gitClone should populate a directory', ->
        @exec.calledWithMatch(/^git clone/).should.be.true
 
      before (done) ->
        @spy = sinon.spy JSON, 'parse'
        @fsRead = sinon.stub fs, 'readFile', (path_, cb) ->
          obj =
            displayName: 'WHEEEE'
            description: 'Whee whee whee'
            gitUrl: 'git://blah.git'
          cb null, JSON.stringify obj
        @fsExists = sinon.stub fs, 'exists', (path_, cb) ->
          cb true
          
        @tool.loadManifest done

      after ->
        JSON.parse.restore()
        fs.readFile.restore()
        fs.exists.restore()
 
      it 'tool.loadManifest should parse the json file', ->
        @fsRead.calledOnce.should.be.true
        @spy.calledOnce.should.be.true

      it 'should have a displayName', ->
        should.exist @tool.manifest.displayName

      it 'should have a description', ->
        should.exist @tool.manifest.description
        
      it 'should have a gitUrl', ->
        should.exist @tool.manifest.gitUrl

