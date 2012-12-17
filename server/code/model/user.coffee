bcrypt = require 'bcrypt'
mongoose = require 'mongoose'
_ = require 'underscore'

userSchema = new mongoose.Schema
  shortname: {type: String, unique: true}
  email: [String]
  displayname: String
  password: String # encrypted, see setPassword method
  apikey: {type: String, unique: true}
  isstaff: Boolean
  created: {type: Date, default: Date.now}

DbUser = mongoose.model 'User', userSchema

class User
  constructor: (@shortName) ->

  checkPassword: (password, callback) ->
    DbUser.findOne {shortname: @shortName}, (err, user) ->
      console.warn err if err?
      if not user? then return callback false

      bcrypt.compare password, user.password, (err, correct) ->
        if correct
          callback true, _.extend(this, user.toObject())
        else
          callback false

module.exports = User
