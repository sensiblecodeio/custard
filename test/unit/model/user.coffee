bcrypt = require 'bcrypt'
User = require 'model/user'

describe 'User', ->
  describe 'password', ->
    user = null
    password = String(Math.random())
    before (done) ->
      hashed = bcrypt.hashSync password, 10
      user = new User('bob', hashed)
      done()

    it 'can be verified as correct', (done) ->
      user.checkPassword password, (res) ->
        res.should.be.true
        done()

    it 'can be verified as wrong', (done) ->
      user.checkPassword 'dfafa', (res) ->
        res.should.be.false
        done()
