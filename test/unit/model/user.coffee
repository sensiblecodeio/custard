bcrypt = require 'bcrypt'
User = require 'model/user'
replay = require 'replay'

describe 'User', ->
  describe 'password', ->
    before (done) ->
      @user = new User('ickletest', 'blah')
      done()

    it 'can be verified as correct', (done) ->
      @user.checkPassword (res) ->
        res.should.be.true
        done()

    it 'can be verified as wrong', (done) ->
      @user.shortName = 'hmm'
      @user.password = 'WRONG'
      @user.checkPassword (res) ->
        res.should.be.false
        done()
