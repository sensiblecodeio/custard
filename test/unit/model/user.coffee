bcrypt = require 'bcrypt'
User = require 'model/user'
replay = require 'replay'


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

    it 'can get the hashed password from cobalt', (done) ->
      User.getHashedPassword 'cotest', (passwd) ->
        passwd.should.equal \
          '$2a$10$e.m.9KUQ2TAhZ9g3Ro7vzOWAbI78lCf3c0auedtmVVXmy0nSGzzsK'
        done()


