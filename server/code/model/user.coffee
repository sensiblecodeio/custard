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

zDbUser = mongoose.model 'User', userSchema

# All server models should extend this class.
class ModelBase
  constructor: (obj) ->
    for k of obj
      @[k] = obj[k]

class User extends ModelBase
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

  objectify: ->
    res = {}
    for k of @
      res[k] = @[k]
    # :todo: maybe split into superclass (above) and this class (below)
    delete res.dbUser
    return res

  save: (callback) ->
    if not @dbInstance?
      @dbInstance = new @constructor.dbClass(@)
    else
      for k of @dbInstance
        @dbInstance[k] = @[k] if @hasOwnProperty k
    @dbInstance.save callback

  @dbClass: zDbUser

  @findByShortName: (shortName, callback) ->
    @dbClass.findOne {shortName: shortName}, (err, user) ->
      if err?
        console.warn err
        callback err, null
      if user?
        callback null, makeUserFromMongo user
      else
        callback null, null

  @findAll: (callback) ->
    @dbClass.find {}, (err, users) ->
      if err?
        console.warn err
        callback err, null
      if users?
        result = for u in users
          makeUserFromMongo u
        callback null, result
      else
        callback null, null

makeUserFromMongo = (user) ->
  newUser = new User {}
  newUser.dbInstance = user
  _.extend newUser, user.toObject()
  return newUser

rand32 = ->
  # 32 bits of lovely randomness.
  # It so happens that Math.random() only generates 32 random
  # bits on V8 (on node.js and Chrome).
  Math.floor(Math.random() * Math.pow(2, 32))

fresh_apikey = ->
  [rand32(), rand32()].join('-')

module.exports = User
