sinon = require 'sinon'
should = require 'should'
_ = require 'underscore'

describe 'Data Request (client)', ->
  helper = require '../helper'
  helper.evalConcatenatedFile 'client/code/model/data_request.coffee'

  describe 'Validation', ->
    beforeEach ->
      @dataRequest = new Cu.Model.DataRequest
      @attrs =
        name: 'Steve Jobs'
        phone: '1-800-MY-APPLE'
        email: 'steve@example.com'
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

request = require 'request'
mongoose = require 'mongoose'

{DataRequest} = require 'model/data_request'

describe 'Data request (server)', ->
  before ->
    @requestStub = sinon.stub request, 'post', (options, cb) ->
      cb null, 'fake request', 9999
    @dataRequest = new DataRequest
      name: 'Steve Jobs'
      phone: '1-800-MY-APPLE'
      email: 'steve@example.com'
      description: 'Thermonuclear war.'
    @emailStub = sinon.stub @dataRequest, 'sendEmail'

  context 'when the data request is sent to the box', ->
    before (done) ->
      @dataRequest.sendToBox done

    it 'the correct data is sent', ->
      correct = @requestStub.calledWith
        uri: "#{process.env.CU_REQUEST_BOX_URL}/exec"
        form:
          apikey: process.env.CU_REQUEST_API_KEY
          cmd: "~/tool/request.py 'Steve Jobs' '1-800-MY-APPLE' 'steve@example.com' 'Thermonuclear war.'"
      correct.should.be.true

    it 'a ticket ID is returned', ->
      @dataRequest.id.should.equal 9999

    it 'sends an email to the customer', ->
      @emailStub.called.should.be.true
