bcrypt = require 'bcrypt'
mongoose = require 'mongoose'
async = require 'async'
request = require 'request'
uuid = require 'uuid'

mailchimp = require('mailchimp')

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
  acceptedTerms: Number # a value of 0 or null means you need to accept terms on next login
  created: {type: Date, default: Date.now}
  logoUrl: String
  sshKeys: [String]

zDbUser = mongoose.model 'User', userSchema

class exports.User extends ModelBase
  @dbClass: zDbUser

  validate: ->
    # TODO: proper regex, share validation across server & client
    return 'invalid shortName' unless /^[a-zA-Z0-9-.]{3,24}$/g.test @shortName
    return 'invalid displayName' unless /^[^<>;\b]+$/g.test @displayName
    return 'invalid email' unless /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/gi.test @email[0]
    return 'please accept the terms and conditions' if isNaN @acceptedTerms

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
      email: opts.newUser.email
      apikey: uuid.v4()
      accountLevel: 'free'
      recurlyAccount: "#{opts.newUser.shortName}.#{recurlyRand}"
      acceptedTerms: opts.newUser.acceptedTerms

    if opts.requestingUser?.isStaff
      newUser.accountLevel = opts.newUser.accountLevel or 'free'
      newUser.acceptedTerms = 0

    if opts.newUser.logoUrl?
      newUser.logoUrl = opts.newUser.logoUrl

    if opts.newUser.emailMarketing?
      try
        api = new mailchimp.MailChimpAPI process.env.CU_MAILCHIMP_API_KEY,
          version: '1.3'
          secure: false
      catch err
        console.warn 'Error connecting to MailChimp API', err.message

      # http://apidocs.mailchimp.com/api/1.3/listsubscribe.func.php
      api.listSubscribe
        id: process.env.CU_MAILCHIMP_LIST_ID
        double_optin: false
        update_existing: true
        email_address: newUser.email[0]
        merge_vars:
          FNAME: newUser.displayName.split(' ')[0]
          LNAME: newUser.displayName.split(' ').pop()
          UNAME: newUser.shortName
      , (err, data) ->
        if err
          console.warn "Error adding user to MailChimp newsletter list", newUser, err
        else if data
          console.log 'User added to MailChimp newsletter list'
        else
          console.log 'MailChimpAPI.listSubscribe() returned false while adding user, but there was no error (!?)', newUser

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
