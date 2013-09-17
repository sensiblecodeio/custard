bcrypt = require 'bcrypt'
mongoose = require 'mongoose'
async = require 'async'
request = require 'request'
uuid = require 'uuid'
_ = require 'underscore'
xml2js = require 'xml2js'

mailchimp = require('mailchimp')

ModelBase = require 'model/base'
{Box} = require 'model/box'
{Token} = require 'model/token'
{Plan} = require 'model/plan'
{Subscription} = require 'model/subscription'

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
  # List of users that can switch into this profile.
  canBeReally: [String]
  defaultContext: String

zDbUser = mongoose.model 'User', userSchema

class exports.User extends ModelBase
  @dbClass: zDbUser

  validate: ->
    # TODO: proper regex, share validation across server & client
    return 'invalid shortName' unless /^[a-zA-Z0-9-.]{3,24}$/g.test @shortName
    return 'invalid displayName' unless /^[^<>;\b]+$/g.test @displayName
    return 'invalid email' unless /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/gi.test @email[0]

  checkPassword: (password, callback) ->
    User.findByShortName @shortName, (err, user) ->
      if err
        return callback {statusCode: 500, error: "Error calling users database"}, null
      if not user
        return callback {statusCode: 404, error: "No such user"}, null
      if not user.password
        return callback {statusCode: 403, error: "User has no password"}, null

      bcrypt.compare password, user.password, (err, correct) ->
        if err
          return callback {statusCode: 500, error: "Error comparing passwords"}, null
        if correct
          return callback null, user
        else
          return callback {statusCode: 401, error: "Incorrect password"}, null

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

  getCurrentSubscription: (callback) ->
    # find the subscription with that plan name
    request.get
      uri: "https://#{process.env.RECURLY_API_KEY}:@#{process.env.RECURLY_DOMAIN}.recurly.com/v2/accounts/#{@recurlyAccount}/subscriptions"
      strictSSL: true
      headers:
        'Accept': 'application/xml'
        'Content-Type': 'application/xml; charset=utf-8'
    , (err, recurlyResp, body) =>
      if err?
        return callback err, null
      else if recurlyResp.statusCode is 404
        return callback { error: "You have no Recurly account. Sign up for a paid plan at http://scraperwiki.com/pricing" }, null
      else if recurlyResp.statusCode isnt 200
        return callback { statusCode: recurlyResp.statusCode, error: recurlyResp.body }, null

      parser = new xml2js.Parser
        ignoreAttrs: true
        explicitArray: false
      parser.parseString body, (err, obj) =>
        if err?
          console.warn err
          return callback { error: "Can't parse Recurly XML" }, null

        if not obj.subscriptions
          return callback { error: "You do not have a paid subscription. Sign up at http://scraperwiki.com/pricing" }, null

        # xml2js converts multiple entities within entities as an array,
        # but a single one is a single object. So we wrap into a list where necessary.
        if not obj.subscriptions.subscription[0]
          obj.subscriptions.subscription = [ obj.subscriptions.subscription ]

        currentSubscription = _.find obj.subscriptions.subscription, (item) =>
          console.log "recurly", item.plan.plan_code, "user", @accountLevel, item.state
          return item.plan.plan_code is @accountLevel and item.state is 'active'

        if not currentSubscription
          console.log 'kitten'
          return callback null, null

        return callback null, new Subscription currentSubscription

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
        box = Box.makeModelFromMongo box
        box.distributeSSHKeys (err, res, body) ->
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

    if opts.newUser?.emailMarketing
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

  @findCanBeReally: (shortName, callback) ->
    @find canBeReally: shortName, callback

exports.dbInject = (dbObj) ->
  User.dbClass = zDbUser = dbObj if dbObj?
  User
