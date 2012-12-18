fs = require 'fs'
path = require 'path'
existsSync = fs.existsSync || path.existsSync
crypto = require 'crypto'
child_process = require 'child_process'
flash = require 'connect-flash'

express = require 'express'
stylus = require 'stylus'
assets = require 'connect-assets'
ejs = require 'ejs'
passport = require 'passport'
LocalStrategy = require('passport-local').Strategy
mongoose = require 'mongoose'
mongoStore = require('connect-mongo')(express)

User = require 'model/user'
Dataset = require 'model/dataset'
Token = require 'model/token'

# Set up database connection
mongoose.connect process.env.CU_DB

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
  email = user.email[0].toLowerCase().trim()
  emailHash = crypto.createHash('md5').update(email).digest("hex")
  avatarUrl = "https://www.gravatar.com/avatar/#{emailHash}"
  session =
    shortName: user.shortName
    displayName: user.displayName
    email: user.email
    apiKey: user.apikey
    avatarUrl: avatarUrl
    isStaff: user.isStaff

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
      maxAge: 60000 * 60 * 24
    secret: process.env.CU_SESSION_SECRET
    store: new mongoStore(url: process.env.CU_DB)

  app.use passport.initialize()
  app.use passport.session()

  app.use express.logger()

  app.use flash()
  app.use express.favicon()

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

# Render login page
app.get '/login/?', (req, resp) ->
  resp.render 'login',
    errors: req.flash('error')

# Allow set-password to be visited by anons
app.get '/set-password/:token/?', (req, resp) ->
  resp.render 'index',
    scripts: js 'app'
    user: JSON.stringify {}
    boxServer: process.env.CU_BOX_SERVER

app.post "/login", (req, resp) ->
  # console.log req.body # XXX debug only, shows passwords, please remove
  passport.authenticate("local",
    successRedirect: "/"
    failureRedirect: "/login"
    failureFlash: true
  )(req,resp)

# TODO: sort out nice way of serving templates
app.get '/tpl/:page', (req, resp) ->
  resp.render req.params.page,
    user: req.user

# Set a password using a token.
# TODO: :token should be in POST body
app.post '/api/token/:token/?', (req, resp) ->
  Token.find req.params.token, (err, token) ->
    if token?.shortName and req.body.password?
      # TODO: token expiration
      User.findByShortName token.shortName, (err, user) ->
        if user?
          user.setPassword req.body.password, ->
            return resp.send 200, user
        else
          console.warn "no User with shortname #{token.shortname} for Token #{token.token}"
          return resp.send 500
    else
      return resp.send 404, error: 'No token/password specified'

app.all '*', ensureAuthenticated

app.get '/logout', (req, resp) ->
  req.logout()
  resp.redirect '/'

app.get '/github-login/?', (req, resp) ->
  resp.send 200, process.env.CU_GITHUB_LOGIN

# API!
checkUserRights = (req, resp, next) ->
  return next() if req.user.effective.shortName == req.params.user
  return resp.send 403, error: "Unauthorised"

checkStaff = (req, resp, next) ->
  console.log 'CHECKSTAFF', req.user.real.shortName, req.user.real.isStaff
  if req.user.real.isStaff
    return next()
  return resp.send 403, error: "Unstafforised"

app.get '/api/:user/datasets/?', checkUserRights, (req, resp) ->
  Dataset.findAllByUserShortName req.user.effective.shortName, (err, datasets) ->
    if err?
      console.log err
      return resp.send 500, error: 'Error trying to find datasets'
    else
      return resp.send 200, datasets

app.get '/api/:user/datasets/:id/?', checkUserRights, (req, resp) ->
  Dataset.findOneById req.params.id, req.user.effective.shortName, (err, dataset) ->
    if err?
      console.log err
      return resp.send 500, error: 'Error trying to find datasets'
    else
      return resp.send 200, dataset

app.get '/api/switch/:username/?', (req, resp) ->
  shortName = req.params.username
  User.findByShortName shortName, (err, user) ->
    if err? or not user?
      resp.send 500, err
    else
      req.user.effective = getSessionUser user
      req.session.save()
      resp.send 200

app.put '/api/:user/datasets/:id/?', checkUserRights, (req, resp) ->
  Dataset.findOneById req.params.id, req.user.effective.shortName, (err, dataset) ->
    if err?
      console.log err
      return resp.send 500, error: 'Error trying to find datasets'
    else
      dataset.displayName = req.body.displayName
      dataset.save() # dataset is a mongoose object
      return resp.send 200, dataset


app.post '/api/:user/datasets/?', checkUserRights, (req, resp) ->
  data = req.body
  dataset = new Dataset req.user.effective.shortName, data.name, data.displayName, data.box
  dataset.save (err) ->
    console.log err if err?
    Dataset.findOneById dataset.id, req.user.effective.shortName, (err, dataset) ->
      console.log err if err?
      resp.send 200, dataset

app.post '/api/:user/?', checkStaff, (req, resp) ->
  shortName = req.params.user
  new User(
    shortName: shortName
    displayName: req.body.displayName
    email: [req.body.email]
  ).save (err) ->
    console.warn err if err?
    User.findByShortName shortName, (err, user) ->
      token = String(Math.random()).replace('0.', '')
      new Token({token: token, shortName: user.shortName}).save (err) ->
        # 201 Created, RFC2616
        userobj = user.objectify()
        userobj.token = token
        return resp.json 201, userobj


app.get '*', (req, resp) ->
  resp.render 'index',
    scripts: js 'app'
    user: JSON.stringify req.user
    boxServer: process.env.CU_BOX_SERVER


# Define Port
port = process.env.CU_PORT or 3001

if existsSync(port) && fs.lstatSync(port).isSocket()
  fs.chmodSync port, 0o600
  child_process.exec "chown www-data #{port}"

# Start Server
app.listen port, ->
  console.log "Listening on #{port}\nPress CTRL-C to stop server."
