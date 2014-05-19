require '../setup_teardown'

sinon = require 'sinon'
should = require 'should'

describe 'Client model: View', ->
  helper = require '../helper'
  unless Cu.Model.Tool?
    helper.evalConcatenatedFile 'client/code/model/tool.coffee'
  unless Cu.Model.View?
    helper.evalConcatenatedFile 'client/code/model/view.coffee'

  describe 'URL', ->
    beforeEach ->
      @tool = Cu.Model.Tool.findOrCreate
        name: 'test-plugin'
        manifest:
          displayName: 'Test Plugin'

      @view = Cu.Model.View.findOrCreate
        user: 'test'
        box: 'box1'
        tool: 'test-plugin'

    it 'has a related tool', ->
      tool = @view.get('tool')
      tool.get('manifest').displayName.should.equal 'Test Plugin'
