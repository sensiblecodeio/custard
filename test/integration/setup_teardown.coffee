require './setup_teardown'
cleaner = require '../cleaner'
{wd40, browser} = require 'wd40'

base_url = process.env.CU_TEST_URL ? 'http://localhost:3001'
login_url = "#{base_url}/login"
logout_url = "#{base_url}/logout"

before (done) ->
    console.log "[scraperwiki global before]"
    cleaner.clear_and_set_fixtures ->
      console.log "Cleared and set fixtures"
      wd40.init ->
        browser.get login_url, done

after (done) ->
    console.log "[scraperwiki global after]"
    browser.quit done
    # done()