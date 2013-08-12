sinon = require 'sinon'
should = require 'should'

helper = require '../helper'
unless Cu.View.ErrorAlert?
  helper.evalConcatenatedFile 'client/code/view/error.coffee'

describe 'View: ErrorAlert', ->
  context 'when we trigger an "error" event on the global event bus', ->
    before ->
      @onErrorStub = sinon.stub Cu.View.ErrorAlert.prototype, 'onError'
      @view = new Cu.View.ErrorAlert
      Backbone.trigger 'error', 'foo'

    it 'calls the onError function', ->
      @onErrorStub.calledOnce.should.be.true
