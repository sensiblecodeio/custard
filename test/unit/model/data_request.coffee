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
        email: 'stevejobs@sharklasers.com'
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
email = require 'lib/email'

describe 'Data request (server)', ->
  before ->
    @dsEmailStub = sinon.stub email, 'dataRequestEmail'
    @customerEmailStub = sinon.stub email, 'dataRequestConfirmation'
    @requestStub = sinon.stub request, 'post', (options, cb) ->
      cb null, {statusCode: 200}, 9999
    @dataRequest = new DataRequest
      name: 'Steve Jobs'
      email: 'stevejobs@sharklasers.com'
      description: 'Thermonuclear war.'
      ip: '8.8.8.8'

  after ->
    email.dataRequestEmail.restore()
    request.post.restore()
    email.dataRequestConfirmation.restore()

  context 'when the data request is sent to the box', ->
    before (done) ->
      @dataRequest.send done

    it 'the correct data is sent', ->
      correct = @requestStub.calledWith
        uri: "#{process.env.CU_REQUEST_BOX_URL}/exec"
        form:
          apikey: process.env.CU_REQUEST_API_KEY
          cmd: "~/tool/request.py 'Steve Jobs' '' 'stevejobs@sharklasers.com' 'Thermonuclear war.' '8.8.8.8'"
      correct.should.be.true

    it 'a ticket ID is returned', ->
      @dataRequest.id.should.equal 9999

    it 'sends an email to the professional services team', ->
      @dsEmailStub.called.should.be.true

    it 'sends an email to the customer', ->
      @customerEmailStub.called.should.be.true
