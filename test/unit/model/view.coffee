sinon = require 'sinon'
should = require 'should'

describe 'Client model: View', ->
  helper = require '../helper'
  helper.evalConcatenatedFile 'client/code/model/tool.coffee'
  helper.evalConcatenatedFile 'client/code/model/view.coffee'

  describe 'URL', ->
    beforeEach ->
      @tool = Cu.Model.Tool.findOrCreate
        name: 'test-plugin'
        displayName: 'Test Plugin'

      @view = Cu.Model.View.findOrCreate
        user: 'test'
        box: 'box1'
        tool: 'test-plugin'

    it 'has a related tool', ->
      tool = @view.get('tool')
      tool.get('displayName').should.equal 'Test Plugin'

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

