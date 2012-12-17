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

# Verify callback for LocalStrategy
verify = (username, password, done) ->
  user = new User username
  user.checkPassword password, (correct, user) ->
    if correct
      emailHash = crypto.createHash('md5').update(user.email[0]).digest("hex")
      avatarUrl = "https://www.gravatar.com/avatar/#{emailHash}"
      sessionUser =
        real:
          shortName: user.shortname
          displayName: user.displayname
          email: user.email
          apiKey: user.apikey
          avatarUrl: avatarUrl
        effective:
          shortName: user.shortname
          displayName: user.displayname
          email: user.email
          apiKey: user.apikey
          avatarUrl: avatarUrl

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

# Avoids "Error: Cannot find module 'ico'"
app.get '/favicon.ico', (req, resp) -> resp.send 404

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

app.all '*', ensureAuthenticated

app.get '/logout', (req, resp) ->
  req.logout()
  resp.redirect '/'

app.get '/github-login/?', (req, resp) ->
  resp.send 200, process.env.CU_GITHUB_LOGIN

# API!
checkUserRights = (req, resp, next) ->
  console.log req.user.shortName, req.params.user
  return next() if req.user.effective.shortName == req.params.user
  return resp.send 403, error: "Unauthorised"

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
  req.user.effective.shortName = req.params.username
  # :todo: make this actually get a user from the user model
  req.user.effective.displayName = 'Switched'
  req.session.save()
  return resp.send 200

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


app.get '*', (req, resp) ->
  console.log 'USER', req.user
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
