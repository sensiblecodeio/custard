bcrypt = require 'bcrypt'
request = require 'request'

class User
  constructor: (@shortName, @password) ->

  checkPassword: (callback) ->
    options =
      uri: "#{window.boxServer}/#{@shortName}/auth"
      form:
        password: @password

    request.post options, (err, resp, body) =>
      if resp.statusCode is 200
        obj = JSON.parse body
        @apiKey = obj.apikey
        @displayName = obj.displayname
        @email = obj.email
        callback true, this
      else
        callback false


module.exports = User
