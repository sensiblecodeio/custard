bcrypt = require 'bcrypt'
User = require 'model/user'
mongoose = require 'mongoose'

describe 'User', ->
  before ->
    mongoose.connect process.env.CU_DB


  describe 'password', ->
    before ->
      @user = new User 'ickletest'
      @password = 'toottoot'

    it 'can be verified as correct', (done) ->
      @user.checkPassword @password, (correct) ->
        correct.should.be.true
        done()

    it 'can be verified as wrong', (done) ->
      @user.checkPassword 'WRONG', (correct) ->
        correct.should.be.false
        done()

    context "when the user doesn't exist", ->
      before ->
        @user = new User 'IDONOTEXIST'

      it 'returns false', (done) ->
        @user.checkPassword @password, (correct) ->
          correct.should.be.false
          done()
