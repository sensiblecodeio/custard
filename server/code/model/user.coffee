bcrypt = require 'bcrypt'

class User
  constructor: (@shortname, @hashedPassword) ->

  checkPassword: (guess, callback) ->
    bcrypt.compare guess, @hashedPassword, (err, res) ->
      if err
        console.log err
        return callback false
      callback res

module.exports = User
