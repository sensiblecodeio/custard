#!/usr/bin/env coffee

fixtures = require('pow-mongodb-fixtures').connect('cu-test')
fixtures.clearAllAndLoad __dirname + '/fixtures.js', (err) ->
  if err
    console.error(err)
    return process.exit(99)
  process.exit(0)

