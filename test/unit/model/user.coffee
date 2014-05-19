require '../setup_teardown'

mongoose = require 'mongoose'
sinon = require 'sinon'
should = require 'should'
_ = require 'underscore'

request = require 'request'
mailchimp = require 'mailchimp'

{User} = require 'model/user'
{Box} = require 'model/box'
{Plan} = require 'model/plan'

email = require 'lib/email'

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

    context "when requesting a password reset email (with correct shortName)", ->
      before (done) ->
        @emailStub = sinon.stub email, 'passwordResetEmail'
        @emailStub.callsArg 1

        User.sendPasswordReset { shortName: 'ickletest' }, (err) =>
          @err = err
          done()

      it 'email.passwordResetEmail is called with a user object and a token string', ->
        arg = @emailStub.lastCall.args[0]
        arg.should.have.length 1
        arg[0].should.have.properties
          shortName: 'ickletest'
          displayName: 'Ickle Test'
          token: '339231725782156'

      it 'no errors are returned', ->
        should.not.exist @err

      it 'it emails the user', ->
        @emailStub.callCount.should.equal 1

    context "when requesting a password reset email (with incorrect shortName)", ->
      before (done) ->
        User.sendPasswordReset { shortName: 'i-do-not-exist' }, (err) =>
          @err = err
          done()

      it 'an error is returned', ->
        should.exist @err
        @err.should.equal 'user not found'

      it 'it does not email the user', ->
        # callCount should still be 1 (no second email has been sent)
        @emailStub.callCount.should.equal 1

    context "when requesting a password reset email (with an email address shared by two profiles)", ->
      before (done) ->
        User.sendPasswordReset { email: 'ickletest@example.org' }, (err) =>
          @err = err
          done()

      it 'no errors are returned', ->
        should.not.exist @err

      it 'it emails the user', ->
        @emailStub.callCount.should.equal 2

    context "when trying to save a new password", ->
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
    it 'I can find one user by its shortname', (done) ->
      User.findByShortName 'ickletest', (err, user) ->
        should.exist user
        user.displayName.should.equal 'Ickle Test'
        done()

    it 'I can find multiple users by their shared email address', (done) ->
      User.findByEmail 'ickletest@example.org', (err, users) ->
        should.exist users
        users.should.have.a.length 2
        users[0].should.have.a.property 'shortName'
        users[1].should.have.a.property 'shortName'
        done()

    it "it returns null when the user doesn't exist", (done) ->
      User.findByShortName 'NONEXIST', (err, user) ->
        should.not.exist err
        should.not.exist user
        done()

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

        @emailStub = sinon.stub email, 'signUpEmail'
        @emailStub.callsArg 2

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
        @mailChimpStub.restore()

      it 'the new user has a recurlyAccount', ->
        should.exist @user.recurlyAccount

      it 'the new user has agreed to a version of the terms and conditions', ->
        should.exist @user.acceptedTerms
        @user.acceptedTerms.should.be.above 0

      it 'the new user does not have a defaultContext', ->
        should.not.exist @user.defaultContext

      it 'it has not contacted the MailChimp API', ->
        @apiStub.listSubscribe.calledOnce.should.be.false

      # TODO: stub database
      xit 'saves the user to the database'

      it 'emails the user', ->
        @emailStub.calledOnce.should.be.true

      it 'the new user is on "free-trial" plan', ->
        @user.accountLevel.should.equal "free-trial"

      it "the new user's plan expires in 30 days", ->
        @user.getPlanDaysLeft().should.equal 30

      context '...waiting a day brings expiration nearer', ->
        before ->
          # Do not use the default argument to .useFakeTimers(): it doesn't work.
          @clock = sinon.useFakeTimers(+(new Date()))
          # 100e6 milliseconds is a bit more than 1 day.
          @clock.tick(100e6)

        it "the new user's plan expires in 29 days", ->
          @user.getPlanDaysLeft().should.equal 29

        after ->
          @clock.restore()

      context '...waiting a month expires the plan', ->
        before ->
          # See above notes about bug in useFakeTimers().
          @clock = sinon.useFakeTimers(+new Date())
          # 100e6 milliseconds is a bit more than 1 day.
          @clock.tick(30 * 100e6)

        it "the new user's plan has expired", ->
          @user.getPlanDaysLeft().should.equal 0

        after ->
          @clock.restore()


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
        @mailChimpStub.restore()

      it 'it has added them to our MailChimp list', ->
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
        @mailChimpStub.restore()

      it 'it has not contacted the MailChimp API', ->
        @apiStub.listSubscribe.calledOnce.should.be.false

    context 'when add is called (with a default context)', ->
      before (done) ->
        User.add
          newUser:
            shortName: 'testerson-loves-work'
            displayName: 'Test Testerson Esq.'
            email: ['test@example.org']
            acceptedTerms: 1
            emailMarketing: false
            defaultContext: 'testersonltd'
        , (err, user) =>
          @user = user
          done err

      it 'the new user has a defaultContext', ->
        should.exist @user.defaultContext
        @user.defaultContext.should.equal 'testersonltd'

      it 'the new user has been added to the other context\'s canBeReally list', (done) ->
        User.findByShortName 'testersonltd', (err, context) ->
          context.canBeReally.should.include 'testerson-loves-work'
          done()


  describe 'Billing details', ->
    before (done) ->
      User.findByShortName 'mediummary', (err, user) =>
        @user = user
        done err

    it 'We can find the user’s hosted recurly admin URL', (done) ->
      @user.getSubscriptionAdminURL (err, url) ->
        should.not.exist err
        should.exist url
        url.should.be.a.string
        url.should.match new RegExp("^https://[^.]+[.]recurly[.]com/account/[a-z0-9]+$")
        done()
