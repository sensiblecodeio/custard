require '../setup_teardown'

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

  context 'when saving a tool with allowedUsers', ->
    before (done) ->
      @tool = new Tool { name: 'newTool', allowedUsers: ['user1', 'user2'] }
      @tool.save done
    before (done) ->
      Tool.findOneByName "newTool", (error, tool) =>
        @foundTool = tool
        done()
    it 'should have saved the allowedUsers field', ->
      @foundTool.should.have.property "allowedUsers"
      @foundTool.allowedUsers.should.eql ['user1', 'user2']

  context 'when saving a tool with allowedPlans', ->
    before (done) ->
      @tool = new Tool { name: 'newerTool', allowedPlans: ['medium-ec2'] }
      @tool.save done
    before (done) ->
      Tool.findOneByName "newerTool", (error, tool) =>
        @foundTool = tool
        done()
    it 'should have saved the allowedPlans field', ->
      @foundTool.should.have.property "allowedPlans"
      @foundTool.allowedPlans.should.eql ['medium-ec2']

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

      it 'should make a directory for the repository', ->
        @exec.firstCall.calledWithMatch(/^mkdir/).should.be.true
      it 'should git init and fetch a repository', ->
        @exec.firstCall.calledWithMatch(/git init && git fetch .* && git checkout FETCH_HEAD/).should.be.true

      it 'should rsync the tool to all box servers', ->
        @exec.calledWithMatch(/^run-this-one rsync .* \/opt\/tools\/ .*premium/).should.be.true
        @exec.calledWithMatch(/^run-this-one rsync .* \/opt\/tools\/ .*free-ec2/).should.be.true
        @exec.calledWithMatch(/^run-this-one rsync .* \/opt\/tools\/ .*ds-ec2/).should.be.true

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

      it 'should rsync the tool to all box servers', ->
        @exec.calledWithMatch(/^run-this-one rsync .* \/opt\/tools\/ .*premium/).should.be.true
        @exec.calledWithMatch(/^run-this-one rsync .* \/opt\/tools\/ .*free-ec2/).should.be.true
        @exec.calledWithMatch(/^run-this-one rsync .* \/opt\/tools\/ .*ds-ec2/).should.be.true

      it 'should fetch the contents of the repository from upstream and check it out', ->
        @exec.calledWithMatch(/git fetch .* && git checkout FETCH_HEAD/).should.be.true

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
