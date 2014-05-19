cleaner = require '../cleaner'

before (done) ->
    console.log "[scraperwiki global before]"

    cleaner.clear_and_set_fixtures ->
      done()

after (done) ->
    console.log "[scraperwiki global after]"
    done()
