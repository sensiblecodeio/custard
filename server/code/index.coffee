net = require 'net'
fs = require 'fs'
path = require 'path'
existsSync = fs.existsSync || path.existsSync
crypto = require 'crypto'
child_process = require 'child_process'

_ = require 'underscore'
express = require 'express'
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

{User} = require 'model/user'
{Dataset} = require 'model/dataset'
Token = require('model/token')()
{Tool} = require 'model/tool'
{Box} = require 'model/box'
{Subscription} = require 'model/subscription'
{Plan} = require 'model/plan'

recurlySign = require 'lib/sign'

# Set up database connection
mongoose.connect process.env.CU_DB,
  server:
    auto_reconnect: true
    socketOptions:
      keepAlive: 1
# Doesn't seem to do much.
mongoose.connection.on 'error', (err) ->
  console.warn "MONGOOSE CONNECTION ERROR #{err}"

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
  if user.email.length
    email = user.email[0].toLowerCase().trim()
    emailHash = crypto.createHash('md5').update(email).digest("hex")
    session.avatarUrl = "https://www.gravatar.com/avatar/#{emailHash}"
  if user.logoUrl?
    session.logoUrl = user.logoUrl
  session

# Verify callback for LocalStrategy
verify = (username, password, done) ->
  user = new User {shortName: username}
  user.checkPassword password, (correct, user) ->
    if correct
      sessionUser =
        real: getSessionUser user
        effective: getSessionUser user
      return done null, sessionUser
    else
      done null, false, message: 'Incorrect username or password'


app.configure ->
  app.use express.bodyParser()
  app.use express.cookieParser( process.env.CU_SESSION_SECRET )
  app.use express.session
    cookie:
      maxAge: 60000 * 60 * 24 * 365
    secret: process.env.CU_SESSION_SECRET
    store: new mongoStore(url: process.env.CU_DB)

  app.use passport.initialize()
  app.use passport.session()

  app.use express.logger() if /staging|production/.test process.env.NODE_ENV

  app.use flash()
  app.use express.favicon(__dirname + '/../../shared/image/favicon.ico', { maxAge: 2592000000 })

  # Trust X-Forwarded-* headers
  app.enable 'trust proxy'


  # Add Connect Assets
  app.use assets({src: 'client'})
  # Set the public folder as static assets
  app.use express.static(process.cwd() + '/shared')

passport.use 'local', new LocalStrategy(verify)


# Set View Engine
app.set 'views', 'server/template'
app.engine 'html', ejs.renderFile
app.set 'view engine', 'html'
js.root = 'code'

# Middleware (for checking users)
checkUserRights = (req, resp, next) ->
  console.log 'CheckUserRights', req.method, req.url, req.user.effective.shortName, req.params.user
  return next() if req.user.effective.shortName == req.params.user
  return resp.send 403, error: "Unauthorised"

checkStaff = (req, resp, next) ->
  if req.user.real.isStaff
    return next()
  return resp.send 403, error: "Unstafforised"

# :todo: more flexible implementation that checks group membership and stuff
checkSwitchUserRights = checkStaff

# Render the main client side app
renderClientApp = (req, resp) ->
  resp.render 'index',
    scripts: js 'app'
    templates: js 'template/index'
    user: JSON.stringify( req.user or {} )
    recurlyDomain: process.env.RECURLY_DOMAIN
    flash: req.flash()
    environment: process.env.NODE_ENV

# Add a view to a dataset
addView = (user, dataset, attributes, callback) ->
  Dataset.findOneById dataset.box, user.shortName, (err, dataset) ->
    if err?
      console.warn err
      return resp.send err.statusCode, error: "Error finding dataset: #{err.body}"
    Box.create user, (err, box) ->
      if err?
        console.warn err
        return resp.send err.statusCode, error: "Error creating box: #{err.body}"
      view =
        box: box.name
        boxServer: box.server
        tool: attributes.tool
        displayName: attributes.displayName
        boxJSON: box.boxJSON
      dataset.views.push view
      dataset.save (err) ->
        if err?
          console.warn err
          return callback {statusCode: 400, error: "Error saving view: #{err}"}, null
        # Update ssh keys. :todo: Doing _all_ the boxes seems like overkill.
        User.distributeUserKeys user.shortName, (err) ->
          if err?
            console.warn "SSH key distribution error"
            err = null
          box.installTool {user: user, toolName: attributes.tool}, (err) ->
            if err?
              console.warn err
              return callback {500, error: "Error installing tool: #{err}"}
            view = _.findWhere dataset.views, box: box.name
            callback null, view

# Render login page
app.get '/login/?', (req, resp) ->
  resp.render 'login',
    errors: req.flash('error')

# Allow set-password, signup, docs, etc, to be visited by anons
app.get '/set-password/:token/?', renderClientApp
app.get '/subscribe/?*', renderClientApp
app.get '/pricing/?*', renderClientApp
app.get '/signup/?*', renderClientApp
app.get '/docs/?*', renderClientApp
app.get '/', renderClientApp

# Switch is protected by a specific function.
app.get '/switch/:username/?', checkSwitchUserRights, (req, resp) ->
  shortName = req.params.username
  console.log "SWITCH #{req.user.effective.shortName} -> #{shortName}"
  User.findByShortName shortName, (err, user) ->
    if err? or not user?
      resp.send 500, err
    else
      req.user.effective = getSessionUser user
      req.session.save()
      resp.writeHead 302,
        location: "/"   # How to give full URL here?
      resp.end()

app.post "/login", (req, resp) ->
  passport.authenticate("local",
    successRedirect: "/"
    failureRedirect: "/login"
    failureFlash: true
  )(req,resp)

# Set a password using a token.
# TODO: :token should be in POST body
app.post '/api/token/:token/?', (req, resp) ->
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

# Add a user
app.post '/api/user/?', (req, resp) ->
  subscribingTo = req.body.subscribingTo
  [err_,subscribingTo] = Plan.getPlan subscribingTo
  # Is money required?
  if not subscribingTo?.$
    subscribingTo = null
  if not req.user?.real?.isStaff and not req.body.subscribingTo?
    if req.body.inviteCode isnt process.env.CU_INVITE_CODE
      return resp.send 403, error: 'Invalid invite code'
  User.add
    newUser:
      shortName: req.body.shortName
      displayName: req.body.displayName
      email: [req.body.email]
      logoUrl: req.body.logoUrl
      accountLevel: req.body.accountLevel
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

app.post '/api/status/?', checkIdent, (req, resp) ->
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


app.get '/api/:user/subscription/:plan/sign/?', (req, resp) ->
  signedSubscription = recurlySign.sign
    subscription:
      plan_code: req.params.plan
  resp.send 200, signedSubscription

app.post '/api/:user/subscription/verify/?', (req, resp) ->
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
      user.setAccountLevel plan.name, (err) ->
        msg = "You've been subscribed to the #{plan.name} plan!"
        if req.user?.effective
          req.user.effective = getSessionUser user
        else
          msg = "#{msg} Please check your email for an activation link."
        req.flash 'info', msg
        req.session.save()
        resp.send 201, success: "Verified and upgraded"

############ AUTHENTICATED ############
app.all '*', ensureAuthenticated

app.get '/logout', (req, resp) ->
  req.logout()
  resp.redirect '/'

# API!
app.get '/api/tools/?', (req, resp) ->
  Tool.findForUser req.user.effective.shortName, (err, tools) ->
    console.log "API about to return"
    resp.send 200, tools

app.post '/api/tools/?', (req, resp) ->
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
        public: publicBool
    # :todo: Should edit the fields of tool, using the key/value
    # pairs in req.body (_.update tool, body). So that for
    # example the gitUrl can be changed and we git clone from the
    # new one.
    # Start updating the tool instances (datasets and views)
    console.log "Starting to update tool instances..."
    tool.updateInstances (err, res) ->
      console.log "Finished updating tool instances. #{err} #{res}"
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
                return resp.send code, tool

app.get '/api/:user/datasets/?', checkUserRights, (req, resp) ->
  Dataset.findAllByUserShortName req.user.effective.shortName, (err, datasets) ->
    if err?
      console.warn err
      return resp.send 500, error: 'Error trying to find datasets'
    else
      return resp.send 200, datasets

# :todo: should :user be part of the dataset URL?
app.get '/api/:user/datasets/:id/?', checkUserRights, (req, resp) ->
  console.log "GET /api/#{req.params.user}/datasets/#{req.params.id}"
  Dataset.findOneById req.params.id, req.user.effective.shortName, (err, dataset) ->
    if err?
      console.warn err
      return resp.send 500, error: 'Error trying to find datasets'
    else if not dataset
      console.warn "Could not find a dataset with {box: '#{req.params.id}', user: '#{req.user.effective.shortName}'}"
      return resp.send 404
    else
      return resp.send 200, dataset

app.get '/api/:user/datasets/:id/views?', checkUserRights, (req, resp) ->
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

app.put '/api/:user/datasets/:id/?', checkUserRights, (req, resp) ->
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


app.post '/api/:user/datasets/?', checkUserRights, (req, resp) ->
  user = req.user.effective
  console.log "AFDASDASD POST dataset user", user
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
      # Save dataset
      body = req.body
      dataset = new Dataset
        box: box.name
        boxServer: box.server
        user: user.shortName
        tool: body.tool
        name: body.name
        displayName: body.displayName
        boxJSON: box.boxJSON

      dataset.save (err) ->
        if err?
          console.warn err
          return resp.send 400, error: "Error saving dataset: #{err}"
        # Update ssh keys. :todo: Doing _all_ the boxes seems like overkill.
        User.distributeUserKeys user.shortName, (err) ->
          if err?
            console.warn "SSH key distribution error"
            err = null
          console.log "TOOL dataset.tool #{dataset.tool} body.tool #{body.tool}"
          box.installTool {user: user, toolName: body.tool}, (err) ->
            if err?
              console.warn err
              return resp.send 500, error: "Error installing tool: #{err}"
            Dataset.findOneById dataset.box, req.user.effective.shortName, (err, dataset) ->
              console.warn err if err?
              resp.send 200, dataset
              addView user, dataset,
                tool: 'datatables-view-tool'
                displayName: 'View in a table' # TODO: use tool object
              , (err, view) ->
                if err?
                  console.warn "Error creating DT view: #{err}"

app.post '/api/:user/datasets/:dataset/views/?', checkUserRights, (req, resp) ->
  user = req.user.effective
  Dataset.findOneById req.params.dataset, (err, dataset) ->
    # Add view to dataset and save
    body = req.body
    addView user, dataset,
      tool: body.tool
      displayName: body.displayName
    , (err, view) ->
      if err?
        resp.send err.error, error: "Error creating view: #{err}"
      else
        resp.send 200, view


# user api is staff-only for now (probably forever)
app.get '/api/user/?', checkStaff, (req, resp) ->
  User.findAll (err, users) ->
    if err?
      console.log err
      return resp.send 500, error: 'Error trying to find users'
    else
      result = for u in users when u.shortName
        getSessionUser u
      return resp.send 200, result

app.post '/api/:user/sshkeys/?', (req, resp) ->
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

app.get '/api/:user/sshkeys/?', (req, resp) ->
  User.findByShortName req.user.effective.shortName, (err, user) ->
    resp.send 200, user.sshKeys

# Catch all other routes, send to client app
app.get '*', renderClientApp

# Define Port
port = process.env.CU_PORT or 3001

if existsSync(port)
  fs.unlinkSync port

# Start Server
app.listen port, ->
  if existsSync(port)
    fs.chmodSync port, 0o600
    child_process.exec "chown www-data #{port}"
  console.log "Listening on #{port}\nPress CTRL-C to stop server."
