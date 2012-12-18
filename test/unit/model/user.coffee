mongoose = require 'mongoose'
should = require 'should'

User = require 'model/user'

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
         user.displayname.should.equal 'Mr Ickle Test'
         done()

     it "returns null when the user doesn't exist", (done) ->
       User.findByShortName 'NONEXIST', (err, user) ->
         should.not.exist err
         should.not.exist user
         done()
