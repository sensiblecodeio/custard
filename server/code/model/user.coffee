bcrypt = require 'bcrypt'
moment = require 'moment'
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

email = require 'lib/email'

userSchema = new mongoose.Schema
  shortName: {type: String, unique: true}
  email: [String]
  displayName: String
  password: String # encrypted, see setPassword method
  apikey: {type: String, unique: true}
  isStaff: Boolean
  accountLevel: String
  planExpires: Date
  lastSeen: Date
  recurlyAccount: {type: String, unique: true}
  acceptedTerms: Number # a value of 0 or null means you need to accept terms on next login
  created: {type: Date, default: Date.now}
  logoUrl: String
  sshKeys: [String]
  # List of users that can switch into this profile.
  canBeReally: [String]
  defaultContext: String
  datasetDisplay: String

zDbUser = mongoose.model 'User', userSchema

# Calls the specified recurly endpoint path (HTTP GET) and
# turns the response into either an error or a javascript object,
# both of which are passed to the specified callback.
requestRecurlyAPI = (path, callback) ->
  if not process.env.RECURLY_API_KEY or not process.env.RECURLY_DOMAIN
    return callback { error: "RECURLY_API_KEY and RECURLY_DOMAIN need setting" }, null
  request.get
    uri: "https://#{process.env.RECURLY_API_KEY}:@#{process.env.RECURLY_DOMAIN}.recurly.com#{path}"
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
      return callback null, obj

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

  setAccountLevel: (plan, callback) ->
    @accountLevel = plan
    @save callback

  getPlanDaysLeft: ->
      now = moment()
      expires = moment(@planExpires)
      daysLeft = Math.ceil(moment.duration(expires-now).asDays())
      if daysLeft < 0
        daysLeft = 0
      return daysLeft

  getCurrentSubscription: (callback) ->
    requestRecurlyAPI "/v2/accounts/#{@recurlyAccount}/subscriptions", (err, obj) =>
      if err
        return callback err, null

      if not obj.subscriptions
        return callback { error: "You do not have a paid subscription. Sign up at http://scraperwiki.com/pricing" }, null

      # xml2js converts multiple entities within entities as an array,
      # but a single one is a single object. So we wrap into a list where necessary.
      if not obj.subscriptions.subscription[0]
        obj.subscriptions.subscription = [ obj.subscriptions.subscription ]

      currentSubscription = _.find obj.subscriptions.subscription, (item) =>
        return item.plan.plan_code is @accountLevel and item.state is 'active'

      if not currentSubscription
        return callback null, null

      return callback null, new Subscription currentSubscription

  getSubscriptionAdminURL: (callback) ->
    requestRecurlyAPI "/v2/accounts/#{@recurlyAccount}", (err, obj) ->
      if err
        return callback err, null

      if not obj.account?.hosted_login_token
        return callback { error: "You do not have a recurly hosted_login_token. Contact hello@scraperwiki.com for help." }, null

      callback null, "https://#{process.env.RECURLY_DOMAIN}.recurly.com/account/#{obj.account.hosted_login_token}"

  @canCreateDataset: (user, callback) ->
    {Dataset} = require 'model/dataset'
    [err_,plan] = Plan.getPlan user.accountLevel
    if not plan?
      return callback
        statusCode: 404
        error: "Plan not found"

    Dataset.countVisibleDatasets user.shortName, (err, count) ->
      if count >= plan.maxNumDatasets
        callback
          statusCode: 402
          error: "You must upgrade your plan to create another dataset"
      else
        callback null, true

  @findByShortName: (shortName, callback) ->
    @dbClass.findOne {shortName: shortName}, (err, user) =>
      if err?
        console.warn err
        callback err, null
      if user?
        callback null, @makeModelFromMongo user
      else
        callback null, null

  @findByEmail: (email, callback) ->
    # Beware: Unlike shortNames, email addresses are not unique in ScraperWiki.
    # Therefore, this function returns a list of matching user objects.
    @dbClass.find {email: email}, (err, users) =>
      if err?
        console.warn err
        callback err, null
      if users?
        callback null, (@makeModelFromMongo user for user in users)
      else
        callback null, null

  @sendPasswordReset: (criteria, callback) ->
    # `criteria` should be an object with either a `shortName` or `email` key.
    # `callback` is called when the mail has been sent: It will be
    # passed a single `err` argument if something goes wrong.

    # Decide if we are fishing by shortName or fishing by email.
    # In either case fishForUser will pass an error and a list to its
    # callback.
    if criteria.shortName
      fishForUser = (cb) ->
        User.findByShortName criteria.shortName, (err, user) ->
          if user
            cb err, [user]
          else
            cb err, []
    else
      fishForUser = (cb) ->
        User.findByEmail criteria.email, cb

    # Add a .token property to each user object.
    getToken = (user, cb) ->
      Token.findByShortName user.shortName, (err, token) ->
        # TODO(drj,zarino) should we just create a token here?
        if not err
          user.token = token.token
        cb null, user

    fishForUser (err, userList) ->
      if userList.length == 0
        callback 'user not found'
      else
        async.map userList, getToken, (err, augmentedUserList) ->
          filteredUserList = _.filter augmentedUserList, (it) -> 'token' of it
          if filteredUserList.length == 0
            callback 'token not found'
          else
            email.passwordResetEmail filteredUserList, (err) ->
              if err?
                callback 'email not sent'
              else
                callback null

  # Add and email the user
  @add: (opts, callback) ->
    recurlyRand = String(Math.random()).replace('0.', '')
    newUser =
      shortName: opts.newUser.shortName
      displayName: opts.newUser.displayName
      email: opts.newUser.email
      apikey: uuid.v4()
      accountLevel: 'free-trial'
      planExpires: undefined
      recurlyAccount: "#{opts.newUser.shortName}.#{recurlyRand}"
      acceptedTerms: opts.newUser.acceptedTerms

    if opts.requestingUser?.isStaff
      newUser.accountLevel = opts.newUser.accountLevel or 'free-trial'
      newUser.acceptedTerms = 0

    if newUser.accountLevel == 'free-trial'
      expirationDate = new Date()
      expirationDate.setDate(expirationDate.getDate() + 30)
      newUser.planExpires = expirationDate

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

    checkDefaultContextExists = (defaultContext, user, callback) ->
      # [defaultContext] should be either a string or undefined
      # [user] should be a user object the defaultContext will be added to
      # [callback] will be passed an error object and a copy of the [user] object
      if defaultContext
        User.findByShortName defaultContext, (err, context) ->
          if context
            user.defaultContext = defaultContext
            return callback null, user
          else
            return callback "Can't find specified default context", null
      else
        return callback null, user

    checkDefaultContextExists opts.newUser.defaultContext, newUser, (err, newUser) ->
      if err
        # there was a problem looking up the defaultContext
        return callback err, null

      # newUser settings are ready: save them into a new model
      new User(newUser).save (err) ->
        if err?
          err.action = 'save'
          return callback err, null

        User.findByShortName newUser.shortName, (err, user) ->
          if user?
            if user.defaultContext
              User.findByShortName user.defaultContext, (err, context) ->
                context.canBeReally.push(newUser.shortName)
                # TODO: Maybe we should handle the unlikely case that
                # this context can't be saved, and we're left with a
                # user with a defaultContext that isn't reflected in
                # the target context's canBeReally field.
                context.save()

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
                  return callback err, null
                else
                  return callback null, userobj
              else
                email.signUpEmail user, token, (err) ->
                  if err?
                    err.action = "email"
                    return callback err, null
                  else
                    return callback null, userobj
          else
            return callback "Can't find user", null

  @findCanBeReally: (shortName, callback) ->
    # find and return all user objects where
    # the canBeReally list includes [shortName]
    @find canBeReally: shortName, callback

exports.dbInject = (dbObj) ->
  User.dbClass = zDbUser = dbObj if dbObj?
  User
