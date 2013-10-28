process.title = 'custard ' + process.argv[2..].join ' '

nodetime = require 'nodetime'

if process.env.NODETIME_KEY
  nodetime.profile
    accountKey: process.env.NODETIME_KEY
    appName: process.env.CU_NODETIME_APP

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
na = require 'nodealytics'
assets = require 'connect-assets'
ejs = require 'ejs'
passport = require 'passport'
LocalStrategy = require('passport-local').Strategy
mongoose = require 'mongoose'
mongoStore = require('connect-mongo')(express)
flash = require 'connect-flash'
eco = require 'eco'
checkIdent = require 'ident-express'
request = require 'request'
{Exceptional} = require 'exceptional-node'

{User} = require 'model/user'
{Dataset} = require 'model/dataset'
{Token} = require 'model/token'
{Tool} = require 'model/tool'
{Box} = require 'model/box'
{Subscription} = require 'model/subscription'
{Plan} = require 'model/plan'
{DataRequest} = require 'model/data_request'

recurlySign = require 'lib/sign'
throttle = require 'throttler-express'
pageTitles = require '../../shared/code/page-titles'

# Set up database connection
mongoose.connect process.env.CU_DB,
  server:
    auto_reconnect: true
    socketOptions:
      keepAlive: 1
# Doesn't seem to do much.
mongoose.connection.on 'error', (err) ->
  console.warn "MONGOOSE CONNECTION ERROR #{err}"

Exceptional.API_KEY = process.env.EXCEPTIONAL_KEY

if /production/.test process.env.NODE_ENV
  na.initialize 'UA-21451224-7', 'scraperwiki.com'
else
  na =
    trackPage: -> return true
    trackEvent: -> return true

# TODO: move into npm module
nodetimeLog = (req, res, next) ->
  matched = _.find app.routes[req.method.toLowerCase()], (route) ->
    if route.regexp.test req.url
      if route.path isnt '*'
        return true
  if matched?
    name = "#{req.method} #{matched.path}"
    res.nodetimePromise = nodetime.time 'Custard request ', name, req.url
    oldSend = res.send
    res.send = (args... ) ->
      res.nodetimePromise.end()
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
    return {}
  [err_, plan] = Plan.getPlan user.accountLevel
  session =
    shortName: user.shortName
    displayName: user.displayName
    email: user.email
    apiKey: user.apikey
    isStaff: user.isStaff
    avatarUrl: "/image/avatar.png"
    accountLevel: user.accountLevel
    recurlyAccount: user.recurlyAccount
    boxEndpoint: Box.endpoint plan.boxServer, ''
    boxServer: plan.boxServer
    acceptedTerms: user.acceptedTerms
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
  User.findCanBeReally user.shortName, (err, canBeReally) ->
    if canBeReally.length == 0
      return callback user
    else
      if user.defaultContext in _.pluck(canBeReally, 'shortName')
        effectiveUser = _.findWhere canBeReally, shortName: user.defaultContext
      else
        effectiveUser = canBeReally[0]
      return callback effectiveUser

# Verify callback for LocalStrategy
verify = (username, password, callback) ->
  user = new User {shortName: username}
  user.checkPassword password, (err, user) ->
    if err
      return callback null, false, { message: err.error }
    if user
      getEffectiveUser user, (effectiveUser) ->
        sessionUser =
          real: getSessionUser user
          effective: getSessionUser effectiveUser
        return callback null, sessionUser

app.configure ->
  app.use express.bodyParser()
  app.use express.cookieParser( process.env.CU_SESSION_SECRET )
  app.use express.session
    cookie:
      maxAge: 60000 * 60 * 24 * 365
    secret: process.env.CU_SESSION_SECRET
    store: new mongoStore({url: process.env.CU_DB, auto_reconnect: true})

  app.use passport.initialize()
  app.use passport.session()

  app.use express.logger() if /staging|production/.test process.env.NODE_ENV

  app.use flash()
  app.use express.favicon(__dirname + '/../../shared/image/favicon.ico', { maxAge: 2592000000 })

  # Trust X-Forwarded-* headers
  app.enable 'trust proxy'


  # Add Connect Assets
  app.use assets({src: 'client'})
  if not /staging|production/.test process.env.NODE_ENV
    # Set the public folder as static assets
    app.use express.static(process.cwd() + '/shared')
  if process.env.NODETIME_KEY
    app.use nodetimeLog

passport.use 'local', new LocalStrategy(verify)


# Set View Engine
app.set 'views', 'server/template'
app.engine 'html', ejs.renderFile
app.set 'view engine', 'html'
js.root = 'code'

# Middleware (for checking users)
checkThisIsMyDataHub = (req, resp, next) ->
  console.log 'checkThisIsMyDataHub', req.method, req.url, req.user.effective.shortName, req.params.user
  return next() if req.user.effective.shortName == req.params.user

  User.findByShortName req.params.user, (err, switchingTo) ->
    if switchingTo?.canBeReally and req.user.real.shortName in switchingTo.canBeReally
      req.user.effective = getSessionUser switchingTo
      req.session.save()
      resp.writeHead 302,
        location: req.url
      resp.end()
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

# Render the main client side app
renderClientApp = (req, resp) ->
  getSessionUsersFromDB req.user, (usersObj) ->
    resp.render 'index',
      nav: ''
      subnav: ''
      content: ''
      scripts: js 'app'
      templates: js 'template/index'
      user: JSON.stringify usersObj
      recurlyDomain: process.env.RECURLY_DOMAIN
      flash: req.flash()
      environment: process.env.NODE_ENV
      loggedIn: 'real' of usersObj

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
          return callback {statusCode: 400, error: "Error saving view: #{err}"}, null
        # Update ssh keys. :todo: Doing _all_ the boxes seems like overkill.
        box.distributeSSHKeys (err) ->
          if err?
            console.warn "SSH key distribution error for #{box.name}"
            err = null
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
  passport.authenticate("local",
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

setPassword = (req, resp) ->
  Token.find req.params.token, (err, token) ->
    if token?.shortName and req.body.password?
      # TODO: token expiration
      User.findByShortName token.shortName, (err, user) ->
        if user?
          user.setPassword req.body.password, ->
            sessionUser =
              real: getSessionUser user
              effective: getSessionUser user
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

dataRequest = (req, resp) ->
  dataRequest = new DataRequest
    name: req.body.name
    phone: req.body.phone
    email: req.body.email
    description: req.body.description
    ip: req.connection.remoteAddress
  dataRequest.send (err) ->
    if err?
      console.warn "Error trying submit data request", err
      return resp.send 500, error: "Error trying submit data request: #{JSON.stringify err}"
    else
      return resp.send 201, dataRequest

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
        msg = "You've been subscribed to the #{plan.name} plan!"
        if req.user?.effective
          req.user.effective = getSessionUser user
        else
          msg = "#{msg} Please check your email for an activation link."
        req.flash 'info', msg
        req.session.save()
        resp.send 201, success: "Verified and upgraded"

renderServerAndClientSide = (options, req, resp) ->
  fs.readFile "client/template/#{options.page}.eco", (err, contentTemplate) ->
    if err?
      console.warn "Template #{options.page} not found when rendering server side"
      return resp.send 500, {error: "Template not found: #{err}"}
    _.extend options, pageTitles.SubNav[options.page]
    options.subnav ?= 'subnav'
    fs.readFile "client/template/#{options.subnav}.eco", (err, subnavTemplate) ->
      fs.readFile "client/template/nav.eco", (err, navTemplate) ->
        getSessionUsersFromDB req.user, (usersObj) ->
          resp.render 'index',
              nav: eco.render navTemplate.toString()
              subnav: """<div class="subnav-wrapper">#{eco.render subnavTemplate.toString(), options}</div>"""
              content: """<div class="#{options.page}">#{eco.render contentTemplate.toString(), {} }</div>"""
              scripts: js 'app'
              templates: js 'template/index'
              user: JSON.stringify usersObj
              recurlyDomain: process.env.RECURLY_DOMAIN
              flash: req.flash()
              environment: process.env.NODE_ENV
              loggedIn: 'real' of usersObj

# Allow set-password, signup, docs, etc, to be visited by anons
# Note: these are NOT regular expressions!!
app.get '/set-password/:token/?', renderClientApp
app.get '/subscribe/?*', renderClientApp

app.get '/pricing/?*', (req, resp) ->
  renderServerAndClientSide page: 'pricing', req, resp

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

app.post '/api/user/?', addUser
app.post '/api/data-request/?', dataRequest

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
    canSet = ['acceptedTerms', 'canBeReally']
    _.extend user, _.pick req.body, canSet
    user.save (err, newUser) ->
      if err?
        resp.send 500, error: err
      else
        resp.send 200, newUser

listDatasets = (req, resp) ->
  Dataset.findAllByUserShortName req.user.effective.shortName, (err, datasets) ->
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
            return resp.send 400, error: "Error saving dataset: #{err}"
          # Update ssh keys. :todo: Doing _all_ the boxes seems like overkill.
          box.distributeSSHKeys (err) ->
            if err?
              console.warn "SSH key distribution error"
              err = null
          console.log "TOOL dataset.tool #{dataset.tool} body.tool #{body.tool}"
          Dataset.findOneById dataset.box, req.user.effective.shortName, (err, dataset) ->
            console.warn err if err?
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
    console.log "**** sshKeys are", user.sshKeys
    user.save (err) ->
      User.distributeUserKeys user.shortName, (err) ->
        if err?
          console.warn "SSHKEY ERROR: #{err}"
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

app.all '*', ensureAuthenticated

app.get '/logout', logout

# API!
app.get '/api/tools/?', listTools
app.post '/api/tools/?', googleAnalytics, postTool

app.put '/api/user/?', updateUser

app.get '/api/:user/datasets/?', checkThisIsMyDataHub, listDatasets
# :todo: should :user be part of the dataset URL?
app.get '/api/:user/datasets/:id/?', checkThisIsMyDataHub, getDataset
app.get '/api/:user/datasets/:id/views/?', checkThisIsMyDataHub, listViews
app.put '/api/:user/datasets/:id/?', checkThisIsMyDataHub, updateDataset
app.post '/api/:user/datasets/?', checkThisIsMyDataHub, addDataset
app.post '/api/:user/datasets/:dataset/views/?', checkThisIsMyDataHub, addView

app.get '/api/user/?', listUsers

app.post '/api/:user/sshkeys/?', addSSHKey
app.get '/api/:user/sshkeys/?', listSSHKeys

app.put '/api/:user/subscription/change/:plan/?', changePlan

# Catch all other routes, send to client app
# eg: /datasets, /dataset/abc1234, /signup/free
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
    Exceptional.handle err
    setTimeout ->
      process.kill process.pid, 'SIGTERM'
    , 500
