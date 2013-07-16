sinon = require 'sinon'
should = require 'should'
_ = require 'underscore'
throttle = require 'lib/throttle'

describe 'Throttle', ->
  beforeEach ->
    @throttleRoute = throttle.throttle (args) -> (args[0].foo)
    
  context 'First time call', ->
    it 'allows the call', ->
      next = sinon.stub()
      @throttleRoute {foo: 'bar'}, {}, next

      next.called.should.be.true

  context 'Multiple calls (before time elapsed)', ->
    it 'denies the call', -> 
      next = sinon.stub()
      @throttleRoute {foo: 'bar'}, {}, next

      @throttleRoute {foo: 'bar'}, {}, next

      next.calledOnce.should.be.true

  context 'Multiple calls (after time elapsed)', ->
    it 'allows the call', ->
      clock = sinon.useFakeTimers();

      next = sinon.stub()
      @throttleRoute {foo: 'bar'}, {}, next

      clock.tick 2000

      @throttleRoute {foo: 'bar'}, {}, next

      next.calledTwice.should.be.true

      clock.restore()
