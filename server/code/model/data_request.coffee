_ = require 'underscore'
request = require 'request'
email = require 'lib/email'

class exports.DataRequest
  constructor: (options) ->
    _.extend this, options

  sendToBox: (cb) ->
    request.post
      uri: "#{process.env.CU_REQUEST_BOX_URL}/exec"
      form:
        apikey: process.env.CU_REQUEST_API_KEY
        cmd: "~/tool/request.py #{@shellEscape @name} #{@shellEscape @phone} #{@shellEscape @email} #{@shellEscape @description}"
    , (err, resp, body) =>
      if err
        cb err
      else if parseInt(body) is NaN
        cb "Returned ticket ID is not a number: #{body}"
      else
        @id = parseInt(body)
        cb null

  send: (cb) ->
    @sendToBox (err) =>
      if err?
        return cb err
      else
        email.dataRequestEmail this, (err) =>
          if err?
            console.warn "Error sending data request email: #{err}"
        return cb()

  shellEscape: (command) ->
    return "'#{command.replace /'/g, "'\"'\"'" }'"