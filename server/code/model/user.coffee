bcrypt = require 'bcrypt'
mongoose = require 'mongoose'

ModelBase = require 'model/base'

userSchema = new mongoose.Schema
  shortName: {type: String, unique: true}
  email: [String]
  displayName: String
  password: String # encrypted, see setPassword method
  apikey: {type: String, unique: true}
  isStaff: Boolean
  created: {type: Date, default: Date.now}

zDbUser = mongoose.model 'User', userSchema

class User extends ModelBase
  @dbClass: zDbUser

  constructor: (obj) ->
    super obj
    if not ('apikey' of obj)
      @apikey = fresh_apikey()
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

  setPassword: (password, callback) ->
    bcrypt.hash password, 10, (err, hash) =>
      callback err, null if err?
      @password = hash
      @save callback

  @findByShortName: (shortName, callback) ->
    @dbClass.findOne {shortName: shortName}, (err, user) =>
      if err?
        console.warn err
        callback err, null
      if user?
        callback null, @makeModelFromMongo user
      else
        callback null, null

rand32 = ->
  # 32 bits of lovely randomness.
  # It so happens that Math.random() only generates 32 random
  # bits on V8 (on node.js and Chrome).
  Math.floor(Math.random() * Math.pow(2, 32))

fresh_apikey = ->
  [rand32(), rand32()].join('-')

module.exports = User
