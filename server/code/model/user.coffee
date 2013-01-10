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

# All server models should extend this class.  All subclasses
# should ensure that they have defined a dbClass field that
# is the database class to use (when finding).  Typically
# this will be something like:
# @dbClass: mongoose.model 'User', userSchema
class ModelBase
  constructor: (obj) ->
    for k of obj
      @[k] = obj[k]

  objectify: ->
    # Prepare the object for transmission.  Converts it to a
    # plain old JavaScript object.  Any uninteresting fields
    # removed.
    res = {}
    for k of @
      res[k] = @[k]
    delete res.dbInstance
    return res

  save: (callback) ->
    if not @dbInstance?
      @dbInstance = new @constructor.dbClass(@)
    else
      for k of @dbInstance
        @dbInstance[k] = @[k] if @hasOwnProperty k
    @dbInstance.save callback

  @findAll: (callback) ->
    @dbClass.find {}, (err, docs) =>
      if err?
        console.warn err
        callback err, null
      if docs?
        result = for d in docs
          @makeModelFromMongo d
        callback null, result
      else
        callback null, null

  @makeModelFromMongo: (mongo_document) ->
    # Takes a Mongo document instance and returns an instance of this
    # model.

    # Note that this cool "new @" thing creates a fresh instance
    # of the same actual class of "this", which will in general
    # be some subclass of ModelBase.
    newModel = new @ {}
    newModel.dbInstance = mongo_document
    _.extend newModel, mongo_document.toObject()
    return newModel

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
