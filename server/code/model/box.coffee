mongoose = require 'mongoose'
async = require 'async'

Schema = mongoose.Schema

ModelBase = require 'model/base'

boxSchema = new Schema
  users: [String]
  name:
    type: String
    index: unique: true
  # maybe host here?

zDbBox = mongoose.model 'Box', boxSchema

class Box extends ModelBase
  @dbClass: zDbBox

  @findAllByUser: (shortName, callback) ->
    @dbClass.find users: shortName, callback

  @findOneByName: (boxName, callback) ->
    @dbClass.findOne name: boxName, callback

  @findUsersByName: (boxName, callback) ->
    @findOneByName boxName, (err, box) ->
      callback err, box?.users

module.exports = (dbObj) ->
  Box.dbClass = zDbBox = dbObj if dbObj?
  Box
