mongoose = require 'mongoose'
sinon = require 'sinon'
should = require 'should'
_ = require 'underscore'

request = require 'request'

describe 'Data Request', ->
  helper = require '../helper'
  helper.evalConcatenatedFile 'client/code/model/data_request.coffee'

  describe 'Validation', ->
    beforeEach ->
      @dataRequest = new Cu.Model.DataRequest
      @attrs =
        name: 'Steve Jobs'
        phone: '1-800-MY-APPLE'
        email: ['steve@example.com']
        description: 'Need data for thermonuclear war against android. Pls help. Kthxbai.'

      @eventSpy = sinon.spy()
      @dataRequest.on 'invalid', @eventSpy

    it 'saves when all fields are valid', ->
      @dataRequest.set @attrs, validate: true
      @eventSpy.called.should.be.false

    it 'errors when name is not valid', ->
      @attrs.name = ''
      @dataRequest.set @attrs, validate: true
      @eventSpy.calledOnce.should.be.true

    it 'errors when email is not valid', ->
      @attrs.email = 'tabby@example.org@DROP TABLES;'
      @dataRequest.set @attrs, validate: true
      @eventSpy.calledOnce.should.be.true
