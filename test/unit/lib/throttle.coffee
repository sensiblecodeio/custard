sinon = require 'sinon'
should = require 'should'
_ = require 'underscore'
throttle = require 'lib/throttle'

describe 'Throttle', ->
  before ->
    @throttleRoute = throttle.throttle (args) -> (args[0].foo)

  context 'First time call', ->
    it 'allows the call', ->
      next = sinon.stub()
      @throttleRoute {foo: 'bar'}, {}, next

      next.called.should.be.true

  context 'Multiple calls (before time elapsed)', ->
    it 'denies the call', ->
      next = sinon.stub()
      @throttleRoute {foo: 'baz'}, {}, next

      @throttleRoute {foo: 'baz'}, {}, next

      next.callCount.should.equal 1

  context 'Multiple calls (after time elapsed)', ->
    it 'allows the call', ->
      clock = sinon.useFakeTimers();

      next = sinon.stub()
      @throttleRoute {foo: 'qux'}, {}, next

      clock.tick 2000

      @throttleRoute {foo: 'qux'}, {}, next

      next.callCount.should.equal 2

      clock.restore()
