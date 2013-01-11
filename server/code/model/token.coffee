mongoose = require 'mongoose'
_ = require 'underscore'

ModelBase = require 'model/base'

tokenSchema = new mongoose.Schema
  token: {type: String, unique: true}
  shortName: String
  created: {type: Date, default: Date.now}

zDbToken = mongoose.model 'Token', tokenSchema

class Token extends ModelBase
  @dbClass: zDbToken

  @find: (token, callback) ->
    @dbClass.findOne {token: token}, (err, token) ->
      if err?
        callback err, null
      else
        newToken = new Token
        _.extend newToken, token.toObject()
        callback null, newToken

module.exports = (dbObj) ->
  zDbToken = dbObj if dbObj?
  Token
