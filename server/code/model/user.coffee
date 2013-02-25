bcrypt = require 'bcrypt'
mongoose = require 'mongoose'
async = require 'async'
request = require 'request'

ModelBase = require 'model/base'
Box = require('model/box')()

userSchema = new mongoose.Schema
  shortName: {type: String, unique: true}
  email: [String]
  displayName: String
  password: String # encrypted, see setPassword method
  apikey: {type: String, unique: true}
  isStaff: Boolean
  created: {type: Date, default: Date.now}
  logoUrl: String
  sshKeys: [String]

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

  # Sends a list of box sshkeys to cobalt for each box a user
  # can access, so cobalt can overwite the authorized_keys for a box
  @distributeUserKeys: (shortName, callback) ->
    Box.findAllByUser shortName, (err, boxes) ->
      async.forEach boxes, (box, boxCb) ->
        # call cobalt with list of sshkeys of box
        # sshkeys <--> user <--> box
        Box.findUsersByName box.name, (err, users) ->
          boxKeys = []
          async.forEach users, (userName, userCb) ->
            User.findByShortName userName, (err, user) ->
              boxKeys = boxKeys.concat user.sshKeys
              userCb()
          , ->
            request.post
              uri: "#{process.env.CU_BOX_SERVER}/#{box.name}/sshkeys"
              form:
                keys: JSON.stringify boxKeys
            , (err, res, body) ->
              try
                obj = JSON.parse body
              catch e
                return boxCb e
              return boxCb obj?.error if obj?.error?
              return boxCb err
      , callback

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

exports.User = User

exports.dbInject = (dbObj) ->
  User.dbClass = zDbUser = dbObj if dbObj?
  User
