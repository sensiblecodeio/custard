sinon = require 'sinon'
should = require 'should'

class TestDb
  save: (callback) ->
    callback null
  @find: (_args, callback) ->
    callback null, [ new Tool(name: 'test'),
      new Tool(name: 'test2')
    ]

Tool = require('model/tool')(TestDb)

describe 'Server model: Tool', ->

  before ->
    @saveSpy = sinon.spy TestDb.prototype, 'save'
    @findSpy = sinon.spy TestDb, 'find'
    @tool = new Tool 'test'

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
