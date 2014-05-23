{parallel} = require 'async'
cleaner = require '../cleaner'
{wd40, browser} = require 'wd40'

base_url = process.env.CU_TEST_URL ? 'http://localhost:3001'
login_url = "#{base_url}/login"
logout_url = "#{base_url}/logout"

before (done) ->
    console.log "[scraperwiki global before]"

    parallel [
      (cb) ->
        cleaner.clear_and_set_fixtures ->
          cb()
      (cb) ->
        wd40.init (err) ->
          if err
            cb new Error("wd40 init error: #{err} -- is your Selenium server running?")
            return
          browser.get base_url, ->
            cb()
    ], done

after (done) ->
    console.log "[scraperwiki global after]"
    if process.env.BROWSER_QUIT
      console.log "Quitting browser"
      return browser.quit done
    done()
