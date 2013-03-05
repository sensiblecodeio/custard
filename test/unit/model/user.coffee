mongoose = require 'mongoose'
sinon = require 'sinon'
should = require 'should'
_ = require 'underscore'

request = require 'request'

User = require('model/user').dbInject()
Box = require('model/box')()

describe 'User (client)', ->
  helper = require '../helper'
  helper.evalConcatenatedFile 'client/code/model/user.coffee'

  describe 'Validation', ->
    before ->
      @attrs =
        displayName: 'Tabby Testerson'
        shortName: 'tabbytest'
        email: 'tabby@example.org'

    beforeEach ->
      @user = new Cu.Model.User
      @attrs = _.clone @attrs

      @eventSpy = sinon.spy()
      #@user.bind 'invalid', (a,b) =>
      #  console.log 'WOT', @user.validationError
      @user.bind 'invalid', @eventSpy

    it 'saves when all fields are valid', ->
      @user.set @attrs, validate: true
      @eventSpy.called.should.be.false

    it 'errors when name is not valid', ->
      @attrs.displayName = '<script>evil</script>'
      @user.set @attrs, validate: true
      @eventSpy.calledOnce.should.be.true

    it 'errors when shortName is not valid', ->
      @attrs.shortName = 'glurble merp merp!!$$$!"$"£%$£^'
      @user.set @attrs, validate: true
      @eventSpy.calledOnce.should.be.true

    it 'errors when email is not valid', ->
      @attrs.email = 'tabby@example.org'
      @user.set @attrs, validate: true
      @eventSpy.calledOnce.should.be.true

describe 'User (Server)', ->
  before ->
    mongoose.connect process.env.CU_DB

  describe 'password', ->
    before ->
      @user = new User {shortName: 'ickletest'}
      @password = 'toottoot'

    it 'can be verified as wrong', (done) ->
      @user.checkPassword 'WRONG', (correct) ->
        correct.should.be.false
        done()

    context "when the user doesn't exist", ->
      before ->
        @user = new User {shortName: 'IDONOTEXIST'}

      it 'returns false', (done) ->
        @user.checkPassword @password, (correct) ->
          correct.should.be.false
          done()

    context "when trying to set a password", ->
      before (done) ->
        @newPassword = String(Math.random()*Math.pow(2,32))
        User.findByShortName 'ickletest', (err, user) =>
          user.setPassword @newPassword, done

      it "sets the password and is correct", (done) ->
        User.findByShortName 'ickletest', (err, user) =>
          user.checkPassword @newPassword, (correct) ->
            correct.should.be.true
            done()

  context 'when trying to find a user', ->
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
    context 'POST /api/<user>/sshkeys', ->
      before ->
        @pigBox = new Box
          users: ['ickletest']
          name: 'pigbox'
        @luxuryPigBox = new Box
          users: ['ehg', 'ickletest']
          name: 'luxurypigbox'
        @request = sinon.stub request, 'post', (opt, cb) ->
          cb null, null, null

      before (done) ->
        @pigBox.save (err) =>
          @luxuryPigBox.save (err) ->
            done null

      context 'when distributing the keys of ickletest', ->
        before (done) ->
          User.distributeUserKeys 'ickletest', done

        it "posts to pigbox with ickletest's ssh keys", ->
          correctArgs = @request.calledWith
            uri: "#{process.env.CU_BOX_SERVER}/pigbox/sshkeys"
            form:
              keys: ['a', 'b', 'c']
          correctArgs.should.be.true

        it "posts to luxurypigbox with ehg's and ickletest's ssh keys", ->
          correctArgs = @request.calledWith
            uri: "#{process.env.CU_BOX_SERVER}/luxurypigbox/sshkeys"
            form:
              keys: ['d', 'e', 'f', 'a', 'b', 'c']
          correctArgs.should.be.true

  describe 'Validation', ->
    beforeEach ->
      @user = new User
        shortName: 'testoo'
        displayName: 'Test Testerson'
        email: ['test@example.org']

    it 'should save if all fields are valid', (done) ->
      @user.save (err) ->
        should.not.exist err
        done()

    it 'should not save if the shortName is invalid', (done) ->
      @user.shortName = 'Test !!!!'
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
