mongoose = require 'mongoose'
Schema = mongoose.Schema

ModelBase = require 'model/base'

viewSchema = new Schema
  name: String
  displayName: String
  box: String

datasetSchema = new Schema
  user: String  # Actually, the owner
  name: String
  displayName: String
  box: String
  views: [viewSchema]
  #views: [{type: String, ref: 'View'}]

zDbDataset = mongoose.model 'Dataset', datasetSchema

class Dataset extends ModelBase
  @dbClass: zDbDataset

  updateStatus: (status, callback) ->
    @status =
      type: status.type
      message: status.message
      updated: new Date()
    @status.type = 'ok' unless status.type in ['ok', 'error']
    @save callback

  @findAllByUserShortName: (name, callback) ->
    @dbClass.find {user: name}, callback

  @findOneByName: (shortName, dsName, callback) ->
    @dbClass.findOne {user: shortName, name: dsName}, callback

  @findOneById: (id, shortName, callback) ->
    @dbClass.findOne {box: id, user: shortName}, callback
      
module.exports = (dbObj) ->
  Dataset.dbClass = zDbDataset = dbObj if dbObj?
  Dataset
