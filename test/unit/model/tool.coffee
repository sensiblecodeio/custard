sinon = require 'sinon'
should = require 'should'
helper = require '../helper'

helper.evalConcatenatedFile 'client/code/model/tool.coffee'

describe 'Tool Model', ->
  it 'exists', ->
    should.exist ToolModel

