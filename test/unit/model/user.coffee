mongoose = require 'mongoose'
sinon = require 'sinon'
should = require 'should'

request = require 'request'

User = require('model/user').dbInject()

Box = require('model/box')()

describe 'User', ->
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
        user.displayName.should.equal 'Mr Ickle Test'
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
