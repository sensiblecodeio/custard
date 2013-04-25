bcrypt = require 'bcrypt'
mongoose = require 'mongoose'
async = require 'async'
request = require 'request'
uuid = require 'uuid'

ModelBase = require 'model/base'
{Box} = require 'model/box'
Token = require('model/token')()
{Plan} = require 'model/plan'

{signUpEmail} = require 'lib/email'

userSchema = new mongoose.Schema
  shortName: {type: String, unique: true}
  email: [String]
  displayName: String
  password: String # encrypted, see setPassword method
  apikey: {type: String, unique: true}
  isStaff: Boolean
  accountLevel: String
  recurlyAccount: {type: String, unique: true}
  trialStarted: {type: Date, default: Date.now}
  created: {type: Date, default: Date.now}
  logoUrl: String
  sshKeys: [String]

zDbUser = mongoose.model 'User', userSchema

class exports.User extends ModelBase
  @dbClass: zDbUser

  validate: ->
    # TODO: proper regex, share validation across server & client
    return 'invalid shortName' unless /^[a-zA-Z0-9-.]{3,24}$/g.test @shortName
    return 'invalid displayName' unless /^[a-zA-Z0-9-. ]+$/g.test @displayName
    return 'invalid email' unless /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/gi.test @email[0]

  checkPassword: (password, callback) ->
    User.findByShortName @shortName, (err, user) ->
      console.warn err if err?
      if not user?.password then return callback false

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

  setDiskQuotasForPlan: (callback) ->
    # Find all their boxes
    Box.findAllByUser @shortName, (err, boxes) =>
      if err
        return callback err, null
      # set quota on each box. Parallel overwhelms gand.
      async.eachSeries boxes, (box, next) =>
        Plan.setDiskQuota box, @accountLevel, next
      , ->
        callback null, true

  setAccountLevel: (plan, callback) ->
    @accountLevel = plan
    @save callback

  @canCreateDataset: (user, callback) ->
    {Dataset} = require 'model/dataset'
    [err_,plan] = Plan.getPlan user.accountLevel
    if not plan?
      return callback
        statusCode: 404
        error: "Plan not found"

    console.log user
    Dataset.countVisibleDatasets user.shortName, (err, count) ->
      if count >= plan.maxNumDatasets
        callback
          statusCode: 402
          error: "You must upgrade your plan to create another dataset"
      else
        callback null, true

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
              uri: "#{Box.endpoint box.server, box.name}/sshkeys"
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

  # Add and email the user
  @add: (opts, callback) ->
    recurlyRand = String(Math.random()).replace('0.', '')
    newUser =
      shortName: opts.newUser.shortName
      displayName: opts.newUser.displayName
      email: [opts.newUser.email]
      apikey: uuid.v4()
      accountLevel: 'free'
      recurlyAccount: "#{opts.newUser.shortName}.#{recurlyRand}"

    if opts.requestingUser?.isStaff
      newUser.accountLevel = opts.newUser.accountLevel or 'free'

    if opts.newUser.logoUrl?
      newUser.logoUrl = opts.newUser.logoUrl

    new User(newUser).save (err) ->
      if err?
        err.action = 'save'
        callback err, null

      User.findByShortName newUser.shortName, (err, user) ->
        if user?
          token = String(Math.random()).replace('0.', '')
          new Token({token: token, shortName: user.shortName}).save (err) ->
            # 201 Created, RFC2616
            userobj = user.objectify()
            # TODO: sort out email templates so we can enable this
            # Don't email if staff are creating at the moment
            if opts.requestingUser?.isStaff is true
              userobj.token = token
              if err?
                err.action = 'token'
                callback err, null
              else
                callback null, userobj
            else
              signUpEmail user, token, (err) ->
                if err?
                  err.action = "email"
                  callback err, null
                else
                  callback null, userobj
        else
          callback "Can't find user", null

exports.dbInject = (dbObj) ->
  User.dbClass = zDbUser = dbObj if dbObj?
  User
