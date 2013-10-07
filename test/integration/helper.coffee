# Shared before/after functions for all integration tests

{wd40, browser} = require 'wd40'
cleaner = require '../cleaner'
request = require 'request'

base_url = 'http://localhost:3001'
login_url = "#{base_url}/login"

prepIntegration = ->
  before (done) ->
    cleaner.clear_and_set_fixtures ->
      wd40.init ->
        browser.get login_url, done

  after (done) ->
    unless process.env.BROWSER_KEEP?
      browser.quit done
    else
      done()

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

exports.wd40 = wd40
exports.browser = browser
exports.base_url = base_url
exports.login_url = login_url
exports.home_url = "#{base_url}/datasets"
exports.prepIntegration = prepIntegration
exports.mediumizeMary = mediumizeMary
