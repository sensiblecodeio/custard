mongoose = require 'mongoose'
Schema = mongoose.Schema

ModelBase = require 'model/base'

datasetSchema = new Schema
  user: String  # Actually, the owner
  name: String
  displayName: String
  box: String

zDbView = mongoose.model 'View', datasetSchema

class View extends ModelBase
  @dbClass: zDbView

  @findAllByUserShortName: (name, callback) ->
    @dbClass.find {user: name}, callback

  @findOneByName: (shortName, dsName, callback) ->
    @dbClass.findOne {user: shortName, name: dsName}, callback

  @findOneById: (id, shortName, callback) ->
    @dbClass.findOne {box: id, user: shortName}, callback
      
module.exports = (dbObj) ->
  View.dbClass = zDbView = dbObj if dbObj?
  View
