_ = require 'underscore'
request = require 'request'
email = require 'lib/email'

class exports.DataRequest
  constructor: (options) ->
    _.extend this, options

  validate: ->
    errors = {}
    unless /^[^<>;]+$/g.test @name
      errors.name = "Please tell us your name"
    unless /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]+$/gi.test @email
      errors.email = "Please tell us your email address"
    if _.size errors
      return errors

  sendToBox: (cb) ->
    request.post
      uri: "#{process.env.CU_REQUEST_BOX_URL}/exec"
      form:
        apikey: process.env.CU_REQUEST_API_KEY
        cmd: "~/tool/request.py #{@shellEscape @name} #{@shellEscape @phone} #{@shellEscape @email} #{@shellEscape @description} #{@shellEscape @ip}"
    , (err, resp, body) =>
      if err
        cb err
      else if resp.statusCode != 200
        cb "Box response: #{resp.statusCode} #{body}"
      else if parseInt(body) is NaN
        cb "Returned ticket ID is not a number: #{body}"
      else
        @id = parseInt(body)
        cb null

  send: (cb) ->
    errors = @validate()
    if errors?
      return cb(errors)
    else
      @sendToBox (err) =>
        if err?
          return cb err
        else
          email.dataRequestEmail this, (err) =>
            if err?
              console.warn "Error sending data request email to professional services team: #{err}"
          email.dataRequestConfirmation this, (err) =>
            if eff?
              console.warn "Error sending data request confirmation to customer: #{err}"
          return cb()

  shellEscape: (command) ->
    if command?
      return "'#{command?.replace /'/g, "'\"'\"'" }'"
    else
      return "''"
