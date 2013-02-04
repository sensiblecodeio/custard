mongoose = require 'mongoose'
Schema = mongoose.Schema

ModelBase = require 'model/base'

viewSchema = new Schema
  name: String
  displayName: String
  box: String
  state: String

datasetSchema = new Schema
  user: String  # Actually, the owner
  name: String
  displayName: String
  box: String
  views: [viewSchema]
  status: Schema.Types.Mixed
  state: String

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

  @findOneById: (id, args...) ->
    if typeof args[0] is 'function'
      @dbClass.findOne {box: id}, (err, doc) =>
        dataset = null
        if doc?
          dataset = Dataset.makeModelFromMongo doc
        args[0](err, dataset)
    else
      @dbClass.findOne {box: id, user: args[0]}, args[1]
      
module.exports = (dbObj) ->
  Dataset.dbClass = zDbDataset = dbObj if dbObj?
  Dataset
