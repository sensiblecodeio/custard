process.title = 'custard ' + process.argv[2..].join ' '

net = require 'net'
fs = require 'fs'
path = require 'path'
existsSync = fs.existsSync || path.existsSync
crypto = require 'crypto'
child_process = require 'child_process'
util = require 'util'
require('http').globalAgent.maxSockets = 4096

_ = require 'underscore'
express = require 'express'
connect = require 'connect'
session = require 'express-session'
serveFavicon = require 'serve-favicon'
cookieParser = require 'cookie-parser'
connect = require 'connect'
na = require 'nodealytics'
assets = require 'connect-assets'
ejs = require 'ejs'
passport = require 'passport'
LocalStrategy = require('passport-local').Strategy
mongoose = require 'mongoose'
mongoStore = require('connect-mongo')(session)
flash = require 'connect-flash'
eco = require 'eco'
checkIdent = require 'ident-express'
request = require 'request'

{User} = require 'model/user'
{Dataset} = require 'model/dataset'
{Token} = require 'model/token'
{Tool} = require 'model/tool'
{Box} = require 'model/box'
{Subscription} = require 'model/subscription'
{Plan} = require 'model/plan'

recurlySign = require 'lib/sign'
throttle = require 'throttler-express'
pageTitles = require '../../shared/code/page-titles'

if not process.env.CU_DB
  console.warn "CU_DB not set. Exiting."
  process.exit 1

# Set up database connection
mongoose.connect process.env.CU_DB,
  server:
    poolSize: 20
    auto_reconnect: true
    socketOptions:
      keepAlive: 1
# Doesn't seem to do much.
mongoose.connection.on 'error', (err) ->
  console.warn "MONGOOSE CONNECTION ERROR #{err}"

if /production/.test process.env.NODE_ENV
  na.initialize 'UA-21451224-7', 'scraperwiki.com'
else
  na =
    trackPage: -> return true
    trackEvent: -> return true

# TODO: move into npm module
requestStream = null
tmpRequestStream = fs.createWriteStream "request.csv", flags: 'a'
tmpRequestStream.on 'open', () ->
  requestStream = tmpRequestStream
requestLog = (req, res, next) ->
  requestStart = new Date()
  unique = Math.random() * Math.pow(2, 32)
  matched = _.find app.routes[req.method.toLowerCase()], (route) ->
    if route.regexp.test req.url
      if route.path isnt '*'
        return true
  if matched?
    name = "#{req.method} #{matched.path}"
    # Rewrites the send method of the response res so that we
    # can time how long it takes between request and response.
    oldSend = res.send
    res.send = (args... ) ->
      duration = new Date() - requestStart
      # CSV file is:
      # app,unique-request-id,route,URL,milliseconds
      line = "custard,#{unique},#{name},#{req.url},#{duration}\n"

      # The first time .send() is called we write a line to the
      # log. Possibly it would be better to use the last time
      # .send() is called, but this is way simpler.
      res.send = oldSend
      if requestStream
        requestStream.write line, () ->
          oldSend.apply res, args
      else
        oldSend.apply res, args
  return next()

assets.jsCompilers.eco =
  match: /\.eco$/
  compileSync: (sourcePath, source) ->
    fileName = path.basename sourcePath, '.eco'
    directoryName = (path.dirname sourcePath).replace "#{__dirname}/template", ""
    jstPath = if directoryName then "#{directoryName}/#{fileName}" else fileName

    """
    (function() {
      this.JST || (this.JST = {});
      this.JST['#{fileName}'] = #{eco.precompile source}
    }).call(this);
    """

app = express()

ensureAuthenticated = (req, res, next) ->
  return next() if req.isAuthenticated()
  res.redirect '/login'

enforceFreeTrial = (req, res, next) ->
  if req.user?.effective
    if req.user.effective.accountLevel == 'free-trial'
      if req.user.effective.daysLeft <= 0
        return res.redirect '/pricing/expired'
  return next()

passport.serializeUser (user, done) ->
  done null, user

passport.deserializeUser (obj, done) ->
  done null, obj

# Convert user into session appropriate user
getSessionUser = (user) ->
  # Guards against the obscure situation when a logged in user
  # (including users who are switched into) has the shortName
  # changed (which can only be done by an admin using the database
  # panel).
  if not user
    console.warn "MYSTERIOUS: user is not in the database"
    return {}
  [err, plan] = Plan.getPlan user.accountLevel
  if err
    # We get here if there is no plan for the user's accountLevel.
    # This "Can't Happen".
    console.warn "MYSTERIOUS: user #{user.shortName} has no plan for their accountLevel #{user.accountLevel}"
    return {}
  session =
    shortName: user.shortName
    displayName: user.displayName
    email: user.email
    apiKey: user.apikey
    isStaff: user.isStaff
    avatarUrl: "/image/avatar.png"
    accountLevel: user.accountLevel
    daysLeft: user.getPlanDaysLeft()
    recurlyAccount: user.recurlyAccount
    boxEndpoint: Box.endpoint plan.boxServer, ''
    boxServer: plan.boxServer
    acceptedTerms: user.acceptedTerms
    created: user.created
    datasetDisplay: user.datasetDisplay
  if user.email.length
    email = user.email[0].toLowerCase().trim()
    emailHash = crypto.createHash('md5').update(email).digest("hex")
    session.avatarUrl = "https://www.gravatar.com/avatar/#{emailHash}"
  if user.logoUrl?
    session.logoUrl = user.logoUrl
  session

# TODO: there should be a better way of doing this
# Get a real + effective user objects from the database,
# return them in a single object, to be injected into index.html
getSessionUsersFromDB = (reqUser, cb) ->
  if not reqUser
    cb {}
  else
    User.findByShortName reqUser.effective.shortName, (err, effectiveUser) ->
      if err then console.warn err
      User.findByShortName reqUser.real.shortName, (err, realUser) ->
        if err then console.warn err
        cb
          real: getSessionUser realUser
          effective: getSessionUser effectiveUser

getEffectiveUser = (user, callback) ->
  # Find all users with user.shortName in their canBeReally list
  User.findCanBeReally user.shortName, (err, canBeReally) ->
    if canBeReally.length == 0
      # User cannot switch into anyone else's context.
      return callback user
    else
      if user.defaultContext in _.pluck(canBeReally, 'shortName')
        # User has a defaultContext, and it is one of the contexts they can switch to.
        effectiveUser = _.findWhere canBeReally, shortName: user.defaultContext
      else
        # User doesn't have a default context, just just pick any old one.
        effectiveUser = canBeReally[0]
      return callback effectiveUser

# Verify callback for LocalStrategy
verify = (username, password, callback) ->
  user = new User {shortName: username}
  user.checkPassword password, (err, user) ->
    if err
      return callback null, false, { message: err.error }
    if user
      # User logged in successfully!
      # Now we need to work out which 'effective'
      # profile they should be logged into...
      getEffectiveUser user, (effectiveUser) ->
        sessionUser =
          real: getSessionUser user
          effective: getSessionUser effectiveUser
        return callback null, sessionUser

app.use connect.urlencoded()
app.use connect.json()
app.use cookieParser( process.env.CU_SESSION_SECRET )
app.use session
  cookie:
    maxAge: 60000 * 60 * 24 * 30
  secret: process.env.CU_SESSION_SECRET
  store: new mongoStore({url: process.env.CU_DB, auto_reconnect: true})

app.use passport.initialize()
app.use passport.session()

app.use express.logger() if /staging|production/.test process.env.NODE_ENV

app.use flash()
app.use serveFavicon(__dirname + '/../../shared/image/favicon.ico', { maxAge: 2592000000 })

# Trust X-Forwarded-* headers
app.enable 'trust proxy'

# Add Connect Assets
# Grepability:
# js =
# "js" is defined in connect assets, and appears in our globals here.
app.use assets({src: 'client'})

# Set the public folder as static assets. In production this route
# is served statically by nginx, so this has no effect. It's
# used in dev, and not harmful in production.
app.use express.static(process.cwd() + '/shared')

if process.env.CU_REQUEST_LOG
  app.use requestLog

passport.use 'local', new LocalStrategy(verify)

# Set View Engine
app.set 'views', 'server/template'
app.engine 'html', ejs.renderFile
app.set 'view engine', 'html'

js.root = 'code'

js_app = js 'app'
js_templates = js 'template/index'

# Middleware (for checking users)
checkThisIsMyDataHub = (req, resp, next) ->
  console.log 'checkThisIsMyDataHub', req.method, req.url, req.user.effective.shortName, req.params.user
  return next() if req.user.effective.shortName == req.params.user

  User.findByShortName req.params.user, (err, switchingTo) ->
    if switchingTo?.canBeReally and req.user.real.shortName in switchingTo.canBeReally
      next()
    else
      return resp.send 403, error: "Unauthorised"

checkStaff = (req, resp, next) ->
  if req.user.real.isStaff
    return next()
  return resp.send 403, error: "Unstafforised"

# :todo: more flexible implementation that checks group membership and stuff
checkSwitchUserRights = (req, res, next) ->
  switchingTo = req.params.username
  console.log "SWITCH #{req.user.effective.shortName} -> #{switchingTo}"
  User.findByShortName switchingTo, (err, user) ->
    if err?
      # findByShortName encountered an unexpected error
      return res.send 500, err
    if not user?
      # findByShortName couldn't find the specified shortName
      return res.send 404, { error: "The specified user does not exist"}
    if req.user.real.isStaff
      # the requesting user is staff: they can switch regardless of canBeReally
      req.switchingTo = user
      return next()
    if user.canBeReally and req.user.real.shortName in user.canBeReally
      # the specified shortName is in the requesting user's canBeReally
      req.switchingTo = user
      return next()
    # otherwise, the specified shortName exists, this is not a staff user,
    # and the shortName is not in canBeReally, which means they can't switch.
    return res.send 403, { error: "#{req.user.real.shortName} cannot switch to #{switchingTo}"}

# Render the HTML container into which Backbone
# and the client-side Custard views are written
renderClientApp = (req, resp) ->
  getSessionUsersFromDB req.user, (usersObj) ->
    resp.render 'index',
      title: 'ScraperWiki'
      nav: ''
      subnav: ''
      content: ''
      scripts: js_app
      templates: js_templates
      user: JSON.stringify usersObj
      recurlyDomain: process.env.RECURLY_DOMAIN
      flash: req.flash()
      environment: process.env.NODE_ENV
      loggedIn: 'real' of usersObj
      intercomAppId: process.env.INTERCOM_APP_ID
      intercomUserHash: getIntercomUserHash req.user?.real.shortName

# Bypass Backbone by parsing and rendering the given
# client-side page to HTML (useful for SEO on docs pages etc)
renderServerAndClientSide = (options, req, resp) ->
  fs.readFile "client/template/#{options.page}.eco", (err, contentTemplate) ->
    if err?
      console.warn "Template #{options.page} not found when rendering server side"
      return resp.send 500, {error: "Template not found: #{err}"}
    _.extend options, pageTitles.PageTitles[options.page]
    options.subnav ?= 'subnav'
    fs.readFile "client/template/#{options.subnav}.eco", (err, subnavTemplate) ->
      fs.readFile "client/template/nav.eco", (err, navTemplate) ->
        getSessionUsersFromDB req.user, (usersObj) ->
          resp.render 'index',
              title: options.title or 'ScraperWiki'
              nav: eco.render navTemplate.toString()
              subnav: """<div class="subnav-wrapper">#{eco.render subnavTemplate.toString(), options}</div>"""
              content: """<div class="#{options.page}">#{eco.render contentTemplate.toString(), {} }</div>"""
              scripts: js_app
              templates: js_templates
              user: JSON.stringify usersObj
              recurlyDomain: process.env.RECURLY_DOMAIN
              flash: req.flash()
              environment: process.env.NODE_ENV
              loggedIn: 'real' of usersObj
              intercomAppId: process.env.INTERCOM_APP_ID
              intercomUserHash: getIntercomUserHash req.user?.real.shortName

# (internal) Get the HMAC hash for the specified user
getIntercomUserHash = (shortName) ->
  hash = null
  if shortName and process.env.INTERCOM_SECRET_KEY
    key = process.env.INTERCOM_SECRET_KEY
    hash = crypto.createHmac('sha256', key).update(shortName).digest('hex')
  return hash

# (internal) Add a view to a dataset
_addView = (user, dataset, attributes, callback) ->
  Dataset.findOneById dataset.box, user.shortName, (err, dataset) ->
    if err?
      console.warn err
      return callback {statusCode: err.statusCode, error: "Error finding dataset: #{err.body}"}
    Box.create user, (err, box) ->
      if err?
        console.warn err
        return callback {statusCode: err.statusCode, error: "Error creating box: #{err.body}"}
      view =
        box: box.name
        boxServer: box.server
        tool: attributes.tool
        displayName: attributes.displayName
        boxJSON: box.boxJSON
        state: 'installing'
      dataset.views.push view
      dataset.save (err) ->
        if err?
          console.warn err
          return callback {statusCode: 500, error: "Error saving view: #{err}"}, null
        box.installTool {user: user, toolName: attributes.tool}, (err) ->
          if err?
            console.warn err
            return callback {500, error: "Error installing tool: #{err}"}
          view = _.findWhere dataset.views, box: box.name
          view.state = 'installed'
          dataset.save (err) ->
            callback null, view

switchUser = (req, resp) ->
  shortName = req.params.username
  switchingTo = req.switchingTo # set by checkSwitchUserRights
  req.user.effective = getSessionUser switchingTo
  req.session.save()
  resp.writeHead 302,
    location: "/datasets"   # How to give full URL here?
  resp.end()

login = (req, resp) ->
  passport.authenticate("local", # see the 'verify' function, above
    successRedirect: "/datasets"
    failureRedirect: "/login"
    failureFlash: true
  )(req,resp)

getToken = (req, resp) ->
  Token.find req.params.token, (err, token) ->
    if token?.shortName
      return resp.send 200, { token: token.token, shortName: token.shortName }
    else
      return resp.send 404, { error: 'Specified token could not be found' }

sendPasswordReset = (req, resp) ->
  # Decide if the query is an email address or a shortName
  console.log "sendPasswordReset", req.body
  query = req.body.query
  if query and '@' in query
    criteria =
      email: query
  else
    criteria =
      shortName: query
  console.log "API criteria", criteria
  User.sendPasswordReset criteria, (err) ->
    if err == 'user not found'
      return resp.send 404, error: 'That username could not be found'
    else if err?
      return resp.send 500, error: "Something went wrong: #{err}"
    else
      return resp.send 200, success: "A password reset link has been emailed to #{query}"

setPassword = (req, resp) ->
  Token.find req.params.token, (err, token) ->
    if token?.shortName and req.body.password?
      # TODO: token expiration
      User.findByShortName token.shortName, (err, user) ->
        if user?
          user.setPassword req.body.password, ->
            # Password successfully set!
            # Set up a new login session for the user
            # (into the right context!)
            getEffectiveUser user, (effectiveUser) ->
              sessionUser =
                real: getSessionUser user
                effective: getSessionUser effectiveUser
              req.user = sessionUser
              req.session.save()
              req.login sessionUser, ->
                return resp.send 200, user
        else
          console.warn "no User with shortname #{token.shortname} for Token #{token.token}"
          return resp.send 500
    else
      return resp.send 404, error: 'No token/password specified'

addUser = (req, resp) ->
  subscribingTo = req.body.subscribingTo
  [err_,subscribingTo] = Plan.getPlan subscribingTo
  # Is money required?
  if not subscribingTo?.$
    subscribingTo = null
  User.add
    newUser:
      shortName: req.body.shortName
      displayName: req.body.displayName
      email: [req.body.email]
      logoUrl: req.body.logoUrl
      accountLevel: req.body.accountLevel
      acceptedTerms: req.body.acceptedTerms
      emailMarketing: req.body.emailMarketing
      defaultContext: req.body.defaultContext
    requestingUser: req.user?.real
  , (err, user) ->
    if err?
      if err.action is 'save' and /duplicate key/.test err.err
        err =
          code: "username-duplicate"
          error: "Username is already taken"
      if not err.error
        err.error = err.err
      console.warn err
      return resp.json 500, err
    else
      return resp.json 201, user

postStatus = (req, resp) ->
  console.log "POST /api/status/ from ident #{req.ident}"
  Dataset.findOneById req.ident, (err, dataset) ->
    if err?
      console.warn err
      return resp.send 500, error: 'Error trying to find dataset'
    else if not dataset
      error = "Could not find a dataset with box: '#{req.ident}'"
      console.warn error
      return resp.send 404, error: error
    else
      dataset.updateStatus
        type: req.body.type
        message: req.body.message
      , (err) ->
        if err?
          console.warn err
          return resp.send 500, error: 'Error trying to update status'
        return resp.send 200, status: 'ok'

# Render login page
app.get '/login/?', (req, resp) ->
  if req.user?.real
    return resp.redirect '/datasets'
  resp.render 'login',
    errors: req.flash('error')

# For Recurly.
signPlan = (req, resp) ->
  signedSubscription = recurlySign.sign
    subscription:
      plan_code: req.params.plan
  resp.send 200, signedSubscription

# Also for Recurly.
verifyRecurly = (req, resp) ->
  Subscription.getRecurlyResult req.body.recurly_token, (err, result) ->
    if err?
      statusCode = err.statusCode or 500
      error = err.error or err
      return resp.send statusCode, error
    User.findByShortName req.params.user, (err, user) ->
      if err?
        statusCode = err.statusCode or 500
        error = err.error or err
        return resp.send statusCode, error
      plan = result.subscription.plan
      console.log 'Subscribed to', plan.plan_code
      user.setAccountLevel plan.plan_code, (err) ->
        if req.user?.effective
          req.user.effective = getSessionUser user
        req.session.save()
        resp.send 201, success: "Verified and upgraded"

# Allow set-password, signup, docs, etc, to be visited by anons
# Note: these are NOT regular expressions!!
app.get '/set-password/?', renderClientApp
app.get '/set-password/:token/?', renderClientApp
app.get '/subscribe/?*', renderClientApp
app.get '/thankyou/?*', renderClientApp

app.get '/pricing/?*', (req, resp) ->
  renderServerAndClientSide page: 'pricing', req, resp

app.get '/signup/community', (req, resp) ->
  resp.redirect '/signup/freetrial'

app.get '/signup/?*', (req, resp) ->
  renderServerAndClientSide {page: "sign-up", subnav: 'signupnav'}, req, resp

app.get '/help/?:section', (req, resp) ->
  req.params.section ?= 'home'
  renderServerAndClientSide {page: "help-#{req.params.section}", section: req.params.section, subnav: 'helpnav'}, req, resp

app.get '/help/?*', (req, resp) ->
  renderServerAndClientSide {page: 'help-home', subnav: 'helpnav'}, req, resp

app.get '/terms/enterprise-agreement/?', (req, resp) ->
  renderServerAndClientSide page: 'terms-enterprise-agreement', req, resp

app.get '/terms/?', (req, resp) ->
  renderServerAndClientSide page: 'terms', req, resp

# Anonymous (ie: logged-out) homepage
app.get '/', (req, resp) ->
  renderServerAndClientSide {page: "home", subnav: null}, req, resp

# Switch is protected by a specific function.
app.get '/switch/:username/?', checkSwitchUserRights, switchUser

app.post "/login", login

# Set a password using a token.
# TODO: :token should be in POST body
app.get '/api/token/:token/?', getToken
app.post '/api/token/:token/?', setPassword

app.post '/api/user/reset-password/?', sendPasswordReset
app.post '/api/user/?', addUser

# :todo: Add IP address check (at the moment, anyone running an identd
# can post to anyone's status).
# throttleRoute = throttle.throttle (req) -> req.ident

app.post '/api/status/?', checkIdent, postStatus

app.get '/api/:user/subscription/:plan/sign/?', signPlan
app.post '/api/:user/subscription/verify/?', verifyRecurly

############ AUTHENTICATED ############

logout = (req, resp) ->
  req.logout()
  resp.redirect '/'

listTools = (req, resp) ->
  Tool.findForUser req.user.effective.shortName, (err, tools) ->
    console.log "API about to return"
    resp.send 200, tools

postTool = (req, resp) ->
  body = req.body
  Tool.findOneByName body.name, (err, tool) ->
    isNew = not tool?
    if tool is null
      publicBool = (body.public is "true")
      tool = new Tool
        name: body.name
        user: req.user.effective.shortName
        type: body.type
        gitUrl: body.gitUrl
        allowedUsers: body.allowedUsers
        allowedPlans: body.allowedPlans
        public: publicBool
    else
      _.extend tool, body
    tool.gitCloneOrPull dir: process.env.CU_TOOLS_DIR, (err, stdout, stderr) ->
      console.log err, stdout, stderr
      if err?
        console.warn err
        return resp.send 500, error: "Error cloning/updating your tool's Git repo"
      tool.loadManifest (err) ->
        if err?
          console.warn err
          tool.deleteRepo ->
            return resp.send 500, error: "Error trying to load your tool's manifest"
        else
          tool.save (err) ->
            console.warn err if err?
            Tool.findOneById tool._id, (err, tool) ->
              console.warn err if err?
              if err?
                console.warn err
                return resp.send 500, error: 'Error trying to find tool'
              else
                code = if isNew then 201 else 200
                if isNew
                  code = 201
                  action = 'create'
                else
                  code = 200
                  action = 'update'
                na.trackEvent 'tools', action, body.name
                return resp.send code, tool

updateUser = (req, resp) ->
  User.findByShortName req.user.real.shortName, (err, user) ->
    console.log "updateUser body is", req.body
    # The attributes that we can set via this API.
    canSet = ['acceptedTerms', 'canBeReally', 'datasetDisplay']
    _.extend user, _.pick req.body, canSet
    user.save (err, newUser) ->
      if err?
        resp.send 500, error: err
      else
        resp.send 200, newUser

listDatasets = (req, resp) ->
  Dataset.findAllByUserShortName req.params.user, (err, datasets) ->
    if err?
      console.warn err
      return resp.send 500, error: 'Error trying to find datasets'
    else
      return resp.send 200, datasets

getDataset = (req, resp) ->
  console.log "GET /api/#{req.params.user}/datasets/#{req.params.id}"
  Dataset.findOneById req.params.id, req.user.effective.shortName, (err, dataset) ->
    if err?
      console.warn err
      return resp.send 500, error: 'Error trying to find datasets'
    else if not dataset
      console.warn "Could not find a dataset with {box: '#{req.params.id}', user: '#{req.user.effective.shortName}'}"
      return resp.send 404, error: "We can't find this dataset, or you don't have permission to access it."
    else
      return resp.send 200, dataset

listViews = (req, resp) ->
  console.log "GET /api/#{req.params.user}/datasets/#{req.params.id}/views"
  Dataset.findOneById req.params.id, req.user.effective.shortName, (err, dataset) ->
    if err?
      console.warn err
      return resp.send 500, error: 'Error trying to find dataset views'
    else if not dataset
      console.warn "Could not find a dataset with {box: '#{req.params.id}', user: '#{req.user.effective.shortName}'}"
      return resp.send 404
    else
      dataset.views (err, views) ->
        console.warn "Error fetching views #{err}" if err?
        return resp.send 200, views

updateDataset = (req, resp) ->
  console.log "PUT /api/#{req.params.user}/datasets/#{req.params.id}"
  Dataset.findOneById req.params.id, req.user.effective.shortName, (err, dataset) ->
    if err?
      console.warn err
      return resp.send 500, error: 'Error trying to find datasets'
    else if not dataset
      console.log "Could not find a dataset with {box: '#{req.params.id}', user: '#{req.user.effective.shortName}'}"
      return resp.send 404
    else
      # :todo: should be more systematic about what can be set this way.
      for k of req.body
        dataset[k] = req.body[k]
      dataset.save()
      return resp.send 200, dataset

addDataset = (req, resp) ->
  user = req.user.effective
  body = req.body
  console.log "POST dataset user", user
  User.canCreateDataset user, (err, can) ->
    if err?
      console.log "USER #{user} CANNOT CREATE DATASET"
      return resp.send err.statusCode, err.error
    Box.create user, (err, box) ->
      if err?
        console.warn err
        return resp.send err.statusCode, error: "Error creating box: #{err.body}"
      console.log "POST dataset boxName=#{box.name}"
      console.log "POST dataset boxServer = #{box.server}"
      # TODO: a box will still be created here
      box.installTool {user: user, toolName: body.tool}, (err) ->
        if err?
          console.warn err
          return resp.send 500, error: "Error installing tool: #{err}"
        # Save dataset
        dataset = new Dataset
          box: box.name
          boxServer: box.server
          user: user.shortName
          tool: body.tool
          name: body.name
          displayName: body.displayName
          boxJSON: box.boxJSON
          creatorShortName: req.user.real.shortName
          creatorDisplayName: req.user.real.displayName

        dataset.save (err) ->
          if err?
            console.warn err
            return resp.send 500, error: "Error saving dataset: #{err}"

          console.log "TOOL dataset.tool #{dataset.tool} body.tool #{body.tool}"

          Dataset.findOneById dataset.box, req.user.effective.shortName, (err, dataset) ->
            if err?
              console.warn err
              return resp.send 500, error: "Error saving dataset: #{err}"

            resp.send 200, dataset
            _addView user, dataset,
              tool: 'datatables-view-tool'
              displayName: 'View in a table' # TODO: use tool object
            , (err, view) ->
              if err?
                console.warn "Error creating DT view: #{err}"

# Add view to dataset and save
addView = (req, resp) ->
  user = req.user.effective
  Dataset.findOneById req.params.dataset, (err, dataset) ->
    if err?
      resp.send 500, error: "Error creating view: #{err}"
    if not dataset
      return resp.send 404, error: "Error creating view: #{req.params.dataset} not found"
    body = req.body
    _addView user, dataset,
      tool: body.tool
      displayName: body.displayName
    , (err, view) ->
      if err?
        resp.send err.error, error: "Error creating view: #{err}"
      else
        resp.send 200, view

listUsers = (req, resp) ->
  User.findCanBeReally req.user.real.shortName, (err, users) ->
    if err?
      console.log err
      return resp.send 500, error: 'Error trying to find users'
    else
      result = for u in users when u.shortName
        getSessionUser u
      return resp.send 200, result

addSSHKey = (req, resp) ->
  User.findByShortName req.user.effective.shortName, (err, user) ->
    if not req.body.key?
      return resp.send 400, error: 'Specify key'
    user.sshKeys.push req.body.key.trim()
    user.save (err) ->
      if err?
        resp.send 500, error: err
      else
        resp.send 200, success: 'ok'

listSSHKeys = (req, resp) ->
  User.findByShortName req.user.effective.shortName, (err, user) ->
    resp.send 200, user.sshKeys

googleAnalytics = (req, resp, next) ->
  na.trackPage "#{req.method} #{req.url}", req.url, ->
    return true
  next()

changePlan = (req, resp) ->
  [err, dummy] = Plan.getPlan req.params.plan
  if err
    return resp.send 500, error: "That plan does not exist!"
  User.findByShortName req.user.real.shortName, (err, user) ->
    if err?
      console.warn "error searching for user model!", err
      return resp.send 500, error: "Couldn't find your user object"
    if not user
      return resp.send 500, error: "No users with the specified shortName"
    user.getCurrentSubscription (err, currentSubscription) ->
      if err?
        return resp.send 404, error: "Couldn't find your subscription"
      if not currentSubscription
        return resp.send 404, error: "You do not have a recurly subscription. Please get one at https://scraperwiki.com/pricing"
      currentSubscription.upgrade req.params.plan, (err, recurlyResp) ->
        if err?
          return resp.send 500, error: "Couldn't change your subscription"
        user.accountLevel = req.params.plan
        user.save (err, user) ->
          if err?
            console.warn "could not save user model!", err
            return resp.send 500, error: "Subscription changed, but user model could not be saved"
          return resp.send 200, user

redirectToRecurlyAdmin = (req, resp) ->
  User.findByShortName req.user.real.shortName, (err, user) ->
    if err?
      return resp.send 500, error: "Couldn't find your user object"
    if not user
      return resp.send 500, error: "No users with the specified shortName"
    user.getSubscriptionAdminURL (err, recurlyAdminUrl) ->
      if err?
        return resp.send 404, error: err.error
      if not recurlyAdminUrl
        return resp.send 404, error: "You do not have a recurly hosted_login_token. Contact hello@scraperwiki.com for help."
      resp.writeHead 302,
        location: recurlyAdminUrl
      resp.end()

# Make a callable to respond to `resp` when intercom replies to us.
intercomResponseHandler = (resp, reason) ->
  (err, intercomResp, body) ->
    if err or intercomResp.statusCode not in [200, 201]
      resp.send 500, error: 'Intercom communication error: ' + reason + " " + intercomResp.statusCode + " " + intercomResp.body
    else
      resp.send 200, success: 'OK'

buildIntercomRequestBody = (endpoint, messageObject) ->
  url: 'https://api.intercom.io/v1/' + endpoint
  headers:
    'Content-Type': 'application/json'
  auth:
    user: process.env.INTERCOM_APP_ID
    pass: process.env.INTERCOM_API_KEY
  body: JSON.stringify messageObject

sendIntercomMessage = (req, resp) ->
  messageObject =
    user_id: req.user.real.shortName
    url: req.body.url
    body: req.body.message

  body = buildIntercomRequestBody 'users/message_threads', messageObject
  request.post body, intercomResponseHandler(resp, 'sendIntercomMessage')

# recursively convert any numeric strings to numbers
numberify = (obj) ->
  if typeof obj == 'object'
    obj[key] = numberify val for key, val of obj
  else if not isNaN parseFloat obj
    obj = parseFloat obj
  return obj

sendIntercomUserData = (req, resp) ->
  messageObject = numberify req.body
  messageObject.user_id = req.user.real.shortName

  body = buildIntercomRequestBody 'users', messageObject
  request.put body, intercomResponseHandler(resp, 'sendIntercomUserData')

sendIntercomTag = (req, resp) ->
  messageObject =
    user_ids: [req.user.real.shortName]
    name: req.body.name
    tag_or_untag: "tag"

  body = buildIntercomRequestBody 'tags', messageObject
  request.post body, intercomResponseHandler(resp, 'sendIntercomTag')

# This does automatic switching if you try to
# access a dataset not in your current data hub
switchContextIfRequiredAndAllowed = (req, resp, next) ->
  datasetID = req.params[0]
  Dataset.findOneById datasetID, (err, dataset) ->
    if dataset
      if dataset.user == req.user.effective.shortName
        return next()
      else
        User.findByShortName dataset.user, (err, switchingTo) ->
          if switchingTo
            if switchingTo?.canBeReally and req.user.real.shortName in switchingTo.canBeReally
              req.user.effective = getSessionUser switchingTo
              req.session.save()
              return next()
            else if req.user.real.isStaff
              req.user.effective = getSessionUser switchingTo
              req.session.save()
              return next()
            else
              resp.status 404
              return resp.render 'not_found'
          else
            resp.status 404
            return resp.render 'not_found'
    else
      resp.status 404
      return resp.render 'not_found'

app.all '*', ensureAuthenticated

app.get '/logout', logout

# API!
app.get '/api/tools/?', listTools
app.post '/api/tools/?', googleAnalytics, postTool

app.put '/api/user/?', updateUser

app.get '/api/:user/datasets/?', checkThisIsMyDataHub, listDatasets
app.get '/api/:user/datasets/:id/?', checkThisIsMyDataHub, getDataset
app.get '/api/:user/datasets/:id/views/?', checkThisIsMyDataHub, listViews
app.put '/api/:user/datasets/:id/?', checkThisIsMyDataHub, updateDataset
app.post '/api/:user/datasets/?', checkThisIsMyDataHub, addDataset
app.post '/api/:user/datasets/:dataset/views/?', checkThisIsMyDataHub, addView

app.get '/api/user/?', listUsers

app.post '/api/:user/sshkeys/?', addSSHKey
app.get '/api/:user/sshkeys/?', listSSHKeys

app.put '/api/:user/subscription/change/:plan/?', changePlan
app.get '/api/:user/subscription/billing', redirectToRecurlyAdmin

app.post '/api/reporting/message/?', sendIntercomMessage
app.post '/api/reporting/user/?', sendIntercomUserData
app.post '/api/reporting/tag/?', sendIntercomTag

# Magic redirects
app.all '*', enforceFreeTrial
app.get /^[/]dataset[/]([a-zA-Z0-9]+)/, switchContextIfRequiredAndAllowed, renderClientApp

# Send all other requests to the client app, eg:
# /datasets
# /signup/free
# /dashboard
# /create-profile
app.get '*', renderClientApp

port = process.env.CU_PORT or 3001

if existsSync(port)
  fs.unlinkSync port

# Start Server
server = app.listen port, ->
  if existsSync(port)
    fs.chmodSync port, 0o660
  console.log "Listening on #{port}\nPress CTRL-C to stop server."

# Wait for all connections to finish before quitting
process.on 'SIGTERM', ->
  process.exit()
  console.log "Gracefully stopping..."
  server.close ->
    console.log "All connections finished, exiting"
    process.exit()

  setTimeout ->
    console.error "Could not close connections in time, forcefully shutting down"
    process.exit 1
  , 30*1000

if /staging|production/.test process.env.NODE_ENV
  process.on 'uncaughtException', (err) ->
    console.warn err
    setTimeout ->
      process.kill process.pid, 'SIGTERM'
    , 500

exports.app = app
