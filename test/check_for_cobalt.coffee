#!/usr/bin/env coffee
#
# Checks that there really is a cobalt available, as otherwise
# various tests fail in a confusing and whimsical way.

request = require "request"

check = (done) ->
  url = "https://" + process.env.CU_BOX_SERVER + "/version"
  console.log "cobalt is " + url

  request.get url, (err, response, body) ->
    if not err and response.statusCode is 200
       # TODO(francis) would be nice if it printed the version
       # console.log body
       done()
    else
       console.error "failed to find cobalt", response.statusCode, err, url
       process.exit 123

exports.check = check

if require.main == module
  check ->
    process.exit 0
