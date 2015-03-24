require '../setup_teardown'

mongoose = require 'mongoose'
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

