mongoose = require 'mongoose'
Schema = mongoose.Schema

ModelBase = require 'model/base'

datasetSchema = new Schema
  user: String  # Actually, the owner
  name: String
  displayName: String
  box: String

zDbDataset = mongoose.model 'Dataset', datasetSchema

class Dataset extends ModelBase
  @dbClass: zDbDataset

  @findAllByUserShortName: (name, callback) ->
    @dbClass.find {user: name}, callback

  @findOneByName: (shortName, dsName, callback) ->
    @dbClass.findOne {user: shortName, name: dsName}, callback

  @findOneById: (id, shortName, callback) ->
    @dbClass.findOne {box: id, user: shortName}, callback
      
module.exports = (dbObj) ->
  zDbDataset = dbObj if dbObj?
  Dataset
