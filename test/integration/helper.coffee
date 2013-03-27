# Shared before/after functions for all integration tests

{wd40, browser} = require('../wd40')
cleaner = require('../cleaner')

home_url = 'http://localhost:3001'
login_url = "#{home_url}/login"

before (done) ->
  console.log "helper before"
  cleaner.clear_and_set_fixtures ->
    wd40.init ->
      browser.get login_url, done

after (done) ->
  console.log "helper after"
  browser.quit ->
    done()

exports.wd40 = wd40
exports.browser = browser
exports.login_url = login_url
exports.home_url = home_url


