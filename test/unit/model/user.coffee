mongoose = require 'mongoose'
sinon = require 'sinon'
should = require 'should'
_ = require 'underscore'

request = require 'request'
mailchimp = require 'mailchimp'

{User} = require 'model/user'
{Box} = require 'model/box'
{Plan} = require 'model/plan'

describe 'User (client)', ->
  helper = require '../helper'
  helper.evalConcatenatedFile 'client/code/model/user.coffee'

  describe 'Validation', ->
    beforeEach ->
      @user = new Cu.Model.User
      @attrs =
        displayName: 'Tabby Testerson'
        shortName: 'tabbytest'
        email: ['tabby@example.org']
        acceptedTerms: 1

      @eventSpy = sinon.spy()
      @user.on 'invalid', @eventSpy

    it 'saves when all fields are valid', ->
      @user.set @attrs, validate: true
      @eventSpy.called.should.be.false

    it 'errors when displayName is not valid', ->
      @attrs.displayName = '<script>evil</script>'
      @user.set @attrs, validate: true
      @eventSpy.calledOnce.should.be.true

    it 'errors when shortName contains invalid characters', ->
      @attrs.shortName = 'glurble merp merp!!$$$!"$"£%$£^'
      @user.set @attrs, validate: true
      @eventSpy.calledOnce.should.be.true

    it 'errors when shortName is less than 3 characters', ->
      @attrs.shortName = 'gl'
      @user.set @attrs, validate: true
      @eventSpy.calledOnce.should.be.true

    it 'errors when shortName is more than 24 characters', ->
      @attrs.shortName = 'aaaaaaaaaaaaaaaaaaaaaaaaa'
      @user.set @attrs, validate: true
      @eventSpy.calledOnce.should.be.true

    it 'errors when email is not valid', ->
      @attrs.email = 'tabby@example.org@DROP TABLES;'
      @user.set @attrs, validate: true
      @eventSpy.calledOnce.should.be.true

    it 'errors when acceptedTerms is not valid', ->
      @attrs.acceptedTerms = 'this is not a number'
      @user.set @attrs, validate: true
      @eventSpy.calledOnce.should.be.true

    it 'errors when acceptedTerms is not supplied', ->
      delete @attrs.acceptedTerms
      @user.set @attrs, validate: true
      @eventSpy.calledOnce.should.be.true

describe 'User (server)', ->
  before ->
    mongoose.connect process.env.CU_DB unless mongoose.connection.db

  describe 'Password', ->
    before ->
      @user = new User {shortName: 'ickletest'}
      @password = 'toottoot'

    it 'can be verified as wrong', (done) ->
      @user.checkPassword 'WRONG', (err, user) ->
        err.should.include {statusCode: 401}
        err.should.include {error: "Incorrect password"}
        should.not.exist user
        done()

    context "when the user doesn't exist", ->
      before ->
        @user = new User {shortName: 'IDONOTEXIST'}

      it 'returns false', (done) ->
        @user.checkPassword @password, (err, user) ->
          err.should.include {statusCode: 404}
          err.should.include {error: "No such user"}
          should.not.exist user
          done()

    context "when the password doesn't exist", ->
      before (done) ->
        User.findByShortName 'nopassword', (err, user) =>
          delete user.password
          user.checkPassword 'nonono', (err) =>
            @err = err
            done()

      it 'returns false', ->
        @err.should.include {statusCode: 403}
        @err.should.include {error: "User has no password"}

    context "when trying to set a password", ->
      before (done) ->
        @newPassword = String(Math.random()*Math.pow(2,32))
        User.findByShortName 'ickletest', (err, user) =>
          user.setPassword @newPassword, done

      it "sets the password and is correct", (done) ->
        User.findByShortName 'ickletest', (err, user) =>
          user.checkPassword @newPassword, (err, user) ->
            should.not.exist err
            user.should.include {shortName: "ickletest"}
            done()

  describe 'Finding', ->
    it 'can find one by its shortname', (done) ->
      # TODO: Stub actual DB calls?
      User.findByShortName 'ickletest', (err, user) ->
        should.exist user
        user.displayName.should.equal 'Ickle Test'
        done()

    it "returns null when the user doesn't exist", (done) ->
      User.findByShortName 'NONEXIST', (err, user) ->
        should.not.exist err
        should.not.exist user
        done()

  describe 'SSH keys', ->
    before ->
      @pigBox = new Box
        users: ['ickletest']
        name: 'pigbox'
      @luxuryPigBox = new Box
        users: ['zarino', 'ickletest']
        name: 'luxurypigbox'
      @request = sinon.stub request, 'post', (opt, cb) ->
        cb null, null, null

    before (done) ->
      @pigBox.save (err) =>
        @luxuryPigBox.save (err) ->
          done null

    after ->
      request.post.restore()

    context 'when distributing the keys of ickletest', ->
      before (done) ->
        User.distributeUserKeys 'ickletest', done

      it "posts to pigbox with ickletest's ssh keys", ->
        correctArgs = @request.calledWithMatch
          uri: "http://#{process.env.CU_BOX_SERVER}/pigbox/sshkeys"
          form:
            keys: '["a","b","c"]'
        correctArgs.should.be.true

  describe 'Validation', ->
    beforeEach ->
      @user = new User
        shortName: 'testoo'
        displayName: 'Tést Testersön'
        email: ['test@example.org']
        acceptedTerms: 1

    it 'should save if all fields are valid', (done) ->
      @user.save (err) ->
        should.not.exist err
        done()

    it 'should not save if the shortName contains invalid chars', (done) ->
      @user.shortName = 'Test !!!!'
      @user.save (err) ->
        should.exist err
        done()

    it 'should not save if the shortName is less than 3 chars', (done) ->
      @user.shortName = 'Te'
      @user.save (err) ->
        should.exist err
        done()

    it 'should not save if the shortName is more than 24 chars', (done) ->
      @user.shortName = 'aaaaaaaaaaaaaaaaaaaaaaaaa'
      @user.save (err) ->
        should.exist err
        done()

    it 'should not save if the displayName is invalid', (done) ->
      @user.displayName = '<script>BAD</script>'
      @user.save (err) ->
        should.exist err
        done()

    it 'should not save if the email is invalid', (done) ->
      @user.email = ['notanemail']
      @user.save (err) ->
        should.exist err
        done()

    it 'should not save if the accepted terms are invalid', (done) ->
      @user.acceptedTerms = 'this is not a number'
      @user.save (err) ->
        should.exist err
        done()

    it 'should not save if the terms have not been accepted', (done) ->
      delete @user.acceptedTerms
      @user.save (err) ->
        should.exist err
        done()

  describe 'Adding a user', ->
    context 'when add is called', ->
      before (done) ->
        @apiStub = listSubscribe: sinon.stub()
        @mailChimpStub = sinon.stub mailchimp, 'MailChimpAPI', =>
          return @apiStub
        User.add
          newUser:
            shortName: 'testerson'
            displayName: 'Test Testerson Esq.'
            email: ['test@example.org']
            acceptedTerms: 1
            emailMarketing: false
        , (err, user) =>
          @user = user
          done err

      after ->
        mailchimp.MailChimpAPI.restore()

      it 'has a recurlyAccount', ->
        should.exist @user.recurlyAccount

      it 'has agreed to a version of the terms and conditions', ->
        should.exist @user.acceptedTerms
        @user.acceptedTerms.should.be.above 0

      it 'has not contacted the MailChimp API', ->
        @apiStub.listSubscribe.calledOnce.should.be.false

      # TODO: stub database
      xit 'saves the user to the database'

      # TODO: stub nodemailer
      xit 'emails the user', ->
        @emailStub.calledOnce.should.be.true

    context 'when add is called (with newsletter opt-in)', ->
      before (done) ->
        @apiStub = listSubscribe: sinon.stub()
        @mailChimpStub = sinon.stub mailchimp, 'MailChimpAPI', =>
          return @apiStub
        User.add
          newUser:
            shortName: 'testerson-loves-email'
            displayName: 'Test Testerson Loves Email'
            email: ['emailme@example.org']
            acceptedTerms: 1
            emailMarketing: true
        , (err, user) =>
          @user = user
          done err

      after ->
        mailchimp.MailChimpAPI.restore()

      it 'has added them to our MailChimp list', ->
        @apiStub.listSubscribe.calledOnce.should.be.true
        @apiStub.listSubscribe.calledWithMatch({ email_address: 'emailme@example.org' }).should.be.true

    context 'when add is called (with newsletter preference undefined)', ->
      before (done) ->
        @apiStub = listSubscribe: sinon.stub()
        @mailChimpStub = sinon.stub mailchimp, 'MailChimpAPI', =>
          return @apiStub
        User.add
          newUser:
            shortName: 'testerson-ignores-email'
            displayName: 'Test Testerson Ignores Email'
            email: ['meh@example.org']
            acceptedTerms: 1
        , (err, user) =>
          @user = user
          done err

      after ->
        mailchimp.MailChimpAPI.restore()

      it 'has not contacted the MailChimp API', ->
        @apiStub.listSubscribe.calledOnce.should.be.false


  describe 'Disk quota', ->

    context 'when updating the quotas for a user', ->
      before (done) ->
        @stub = sinon.stub Plan, 'setDiskQuota', (box, plan, cb) ->
          cb null, true

        User.findByShortName 'ehg', (err, user) =>
          @user = user
          user.setDiskQuotasForPlan done

      after ->
        Plan.setDiskQuota.restore()

      it "should update the disk quota for each dataset", ->
        correctArgs = @stub.calledWithMatch {name: '3006375731'}, 'grandfather-ec2'
        correctArgs.should.be.true
        correctArgs = @stub.calledWithMatch {name: '3006375815'}, 'grandfather-ec2'
        correctArgs.should.be.true
