bcrypt = require 'bcrypt'
mongoose = require 'mongoose'
_ = require 'underscore'

userSchema = new mongoose.Schema
  shortName: {type: String, unique: true}
  email: [String]
  displayName: String
  password: String # encrypted, see setPassword method
  apikey: {type: String, unique: true}
  isStaff: Boolean
  created: {type: Date, default: Date.now}

DbUser = mongoose.model 'User', userSchema

class User
  constructor: (obj) ->
    for k of obj
      @[k] = obj[k]
    @

  checkPassword: (password, callback) ->
    User.findByShortName @shortName, (err, user) ->
      console.warn err if err?
      if not user? then return callback false

      bcrypt.compare password, user.password, (err, correct) ->
        if correct
          callback true, user
        else
          callback false

  objectify: ->
    res = {}
    for k of @
      res[k] = @[k]
    console.log "OBJECTIFY #{JSON.stringify(res)}"
    return res

  save: (callback) ->
    console.log "SAVE", @
    console.dir @
    new DbUser(@).save callback

  @findByShortName: (shortName, callback) ->
    DbUser.findOne {shortName: shortName}, (err, user) ->
      if err?
        console.warn err
        callback err, null

      if user?
        newUser = new User {}
        _.extend newUser, user.toObject()
        callback null, newUser
      else
        callback null, null

module.exports = User
