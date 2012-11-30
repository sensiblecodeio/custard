bcrypt = require 'bcrypt'
request = require 'request'

INT_TEST_SRV = 'https://boxecutor-dev-1.scraperwiki.net'

class User
  constructor: (@shortname, @hashedPassword) ->

  checkPassword: (guess, callback) ->
    return callback(false) unless @hashedPassword?
    console.warn guess, @hashedPassword
    bcrypt.compare guess, @hashedPassword, (err, res) ->
      console.log 'sdsdhusfuhsfhusfuhsf'
      if err
        console.log err
        return callback(false)
      callback res

  @getHashedPassword: (shortname, callback) ->
    request.get "#{INT_TEST_SRV}/#{shortname}/password", (err, resp, body) ->
      if resp.statusCode is 200
        callback JSON.parse(body).password
      else
        callback null


module.exports = User
