express = require 'express'
stylus = require 'stylus'
assets = require 'connect-assets'
cons = require 'consolidate'
passport = require 'passport'
LocalStrategy = require('passport-local').Strategy

ensureAuthenticated = (req, res, next) ->
  return next() if req.isAuthenticated()
  res.redirect '/login'

passport.serializeUser (user, done) ->
  done null, user

passport.deserializeUser (obj, done) ->
  done null, obj

app = express()

app.configure ->
  app.use express.bodyParser()
  app.use express.cookieParser('SECRET')
  app.use express.session({ cookie: { maxAge: 60000 }, secret: 'SECRET'})

  app.use passport.initialize()
  app.use passport.session()

  # Add Connect Assets
  app.use assets({src: 'client'})
  # Set the public folder as static assets
  app.use express.static(process.cwd() + '/shared')
  # Set View Engine
  app.set 'views', 'server/template'
  app.engine 'html', cons.jazz
  app.set 'view engine', 'html'
  js.root = 'code'

# Avoids "Error: Cannot find module 'ico'"
app.get '/favicon.ico', (req, resp) -> resp.send 404

# TODO: sort out nice way of serving templates
app.get '/tpl/:page', (req, resp) ->
  resp.render req.params.page

# Render login page
app.get '/login/?', (req, resp) ->
  resp.render 'login'

app.all '*', ensureAuthenticated

app.get '*', (req, resp) ->
  resp.render 'index', { scripts: js 'app' }

# Define Port
port = process.env.PORT or process.env.VMC_APP_PORT or 3000
# Start Server
app.listen port, ->
  console.log "Listening on #{port}\nPress CTRL-C to stop server."
