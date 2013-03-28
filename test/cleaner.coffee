#!/usr/bin/env coffee

clear_and_set_fixtures = (done) ->
  fixtures = require('pow-mongodb-fixtures').connect('cu-test')
  fixtures.clearAllAndLoad __dirname + '/../fixtures.js', (err) ->
    if err
      console.error(err)
      return process.exit(99)
    done()

exports.clear_and_set_fixtures = clear_and_set_fixtures

if require.main == module
  clear_and_set_fixtures ->
    process.exit 0
