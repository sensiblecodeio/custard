require './setup_teardown'
# Shared before/after functions for all integration tests

{wd40, browser} = require 'wd40'
cleaner = require '../cleaner'
request = require 'request'

base_url = process.env.CU_TEST_URL ? 'http://localhost:3001'
login_url = "#{base_url}/login"
logout_url = "#{base_url}/logout"

prepIntegration = ->
  before (done) ->
    done(new Error("prepIntegration is deprecated."))

loginAndGo = (who, password, url, done) ->
  # Login as `who` with `password` if we're not already `who`
  # before navigating to `url`.

  target_url = "#{base_url}#{url}"

  browser.eval "window.user", (err, value) ->
    return done(err) if err

    doLogin = (cb) ->
      browser.get login_url, ->
        wd40.fill '#username', who, ->
          wd40.fill '#password', password, ->
            wd40.click '#login', ->
              browser.get target_url, ->
                cb()

    if value?.real?.shortName == who
      # Already logged in as the right user, go straight there
      # This is an optimization to avoid logging in unncessarily.
      browser.get target_url, ->
        browser.eval "window.location.href", (err, value) ->
          return done(err) if err

          if value != target_url
            # We didn't make our way to the target.
            # This could happen if the database is cleared.
            return browser.get logout_url, -> doLogin(done)
          done()
      return

    # console.log "Logging out because we're the wrong user"
    # We're logged in, but the wrong user or not on the scraperwiki site.
    # Go via the logout_url.
    browser.get logout_url, -> doLogin(done)


mediumizeMary = (done) ->
  # Ensures medium-mary starts on the right plan

  sub_uuid = '21cc59ce00cb05f2bbc397452a99369c' # medium-mary's subscription
  domain = process.env.RECURLY_DOMAIN
  pub_key = process.env.RECURLY_API_KEY

  request.put "https://#{domain}.recurly.com/v2/subscriptions/#{sub_uuid}",
    auth:
      user: pub_key
      pass: ''
    body: '<subscription><plan_code>medium-ec2</plan_code></subscription>'
  , done

enlargeLucy = (done) ->
  # Ensures large-lucy starts on the right plan

  sub_uuid = '2131e1fac6fc3d58299a94414bba462e' # large-lucy's subscription
  domain = process.env.RECURLY_DOMAIN
  pub_key = process.env.RECURLY_API_KEY

  request.put "https://#{domain}.recurly.com/v2/subscriptions/#{sub_uuid}",
    auth:
      user: pub_key
      pass: ''
    body: '<subscription><plan_code>large-ec2</plan_code></subscription>'
  , done

exports.wd40 = wd40
exports.browser = browser
exports.base_url = base_url
exports.login_url = login_url
exports.logout_url = logout_url
exports.home_url = "#{base_url}/datasets"
exports.prepIntegration = prepIntegration
exports.mediumizeMary = mediumizeMary
exports.enlargeLucy = enlargeLucy
exports.loginAndGo = loginAndGo