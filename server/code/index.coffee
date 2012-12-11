fs = require 'fs'
path = require 'path'
existsSync = fs.existsSync || path.existsSync
crypto = require 'crypto'
child_process = require 'child_process'

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

# Passport.js strategy
strategy = (username, password, done) ->
  user = new User(username, password)
  user.checkPassword (correct, user) ->
    if correct
      emailHash = crypto.createHash('md5').update(user.email[0]).digest("hex")
      avatarUrl = "https://www.gravatar.com/avatar/#{emailHash}"
      sessionUser =
        shortName: user.shortName
        displayName: user.displayName
        email: user.email
        apiKey: user.apiKey
        avatarUrl: avatarUrl

      return done null, sessionUser
    else
      done null, false, message: 'WRONG'


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

  # Trust X-Forwarded-* headers
  app.enable 'trust proxy'


  # Add Connect Assets
  app.use assets({src: 'client'})
  # Set the public folder as static assets
  app.use express.static(process.cwd() + '/shared')

passport.use 'local', new LocalStrategy(strategy)


# Set View Engine
app.set 'views', 'server/template'
app.engine 'html', ejs.renderFile
app.set 'view engine', 'html'
js.root = 'code'

# Avoids "Error: Cannot find module 'ico'"
app.get '/favicon.ico', (req, resp) -> resp.send 404

# Render login page
app.get '/login/?', (req, resp) ->
  resp.render 'login'

# Allow set-password to be visited by anons
app.get '/set-password/:token/?', (req, resp) ->
  resp.render 'index',
    scripts: js 'app'
    user: JSON.stringify {}

app.post "/login", passport.authenticate("local",
  successRedirect: "/"
  failureRedirect: "/login"
  failureFlash: false
)

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
app.get '/api/:user/datasets/?', (req, resp) ->
  Dataset.findAllByUserShortName req.user.shortName, (err, datasets) ->
    if err?
      console.log err
      return resp.send 500, error: 'Error trying to find datasets'
    else
      return resp.send 200, datasets

app.get '/api/:user/datasets/:id/?', (req, resp) ->
  Dataset.findOneById req.params.id, req.user.shortName, (err, dataset) ->
    if err?
      console.log err
      return resp.send 500, error: 'Error trying to find datasets'
    else
      return resp.send 200, dataset


app.post '/api/:user/datasets/?', (req, resp) ->
  data = req.body
  dataset = new Dataset req.user.shortName, data.name, data.box
  dataset.save (err) ->
    console.log err if err?
    Dataset.findOneById dataset.id, req.user.shortName, (err, dataset) ->
      console.log err if err?
      resp.send 200, dataset


app.get '*', (req, resp) ->
  resp.render 'index',
    scripts: js 'app'
    user: JSON.stringify req.user


# Define Port
port = process.env.CU_PORT or 3001

if existsSync(port) && fs.lstatSync(port).isSocket()
  fs.chmodSync port, 0o600
  child_process.exec "chown www-data #{port}"

# Start Server
app.listen port, ->
  console.log "Listening on #{port}\nPress CTRL-C to stop server."
