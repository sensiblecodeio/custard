_ = require 'underscore'
request = require 'request'

class exports.DataRequest
  constructor: (options) ->
    _.extend this, options
    @id = 9999

  sendToBox: (cb) ->
    cb()

  email: (cb) ->
    cb()

  send: (cb) ->
    cb()
