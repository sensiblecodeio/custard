mongoose = require 'mongoose'

tokenSchema = new mongoose.Schema
  token: {type: String, unique: true}
  shortName: String
  created: {type: Date, default: Date.now}

DbToken = mongoose.model 'Token', tokenSchema

class Token
  constructor: (obj) ->
    for k of obj
      @[k] = obj[k]
    @

  objectify: ->
    res = {}
    for k of @
      res[k] = @[k]
    res

  save: (callback) ->
    new DbToken(@).save callback

  @find: (token, callback) ->
    DbToken.findOne {token: token}, (err, token) ->
      if err?
        callback err, null
      else
        newToken = new Token
        _.extend newToken, this.toObject()
        callback null, newToken

module.exports = Token
