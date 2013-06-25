_ = require 'underscore'
request = require 'request'

class exports.DataRequest
  constructor: (options) ->
    _.extend this, options
    @id = 9999

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
        @id = body
        cb null

  sendEmail: (cb) ->
    cb()

  send: (cb) ->
    @sendToBox (err) =>
      if err?
        return cb err
      else
        @sendEmail (err) =>
          if err?
            return cb err
          else
            return cb()

  shellEscape: (command) ->
    return "'#{command.replace /'/g, "'\"'\"'" }'"