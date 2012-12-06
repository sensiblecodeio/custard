mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.ObjectId

datasetSchema = new Schema
  user: String
  name: String
  box: String

DbDataset = mongoose.model 'Dataset', datasetSchema

class Dataset
  constructor: (@user, @name, @box) ->

  save: (done) ->
    ds = new DbDataset
      user: @user
      name: @name
      box: @box

    ds.save done

  @findAllByUserShortName: (name, callback) ->
    DbDataset.find {user: name}, callback

  @findOneByName: (shortName, dsName, callback) ->
    DbDataset.findOne {user: shortName, name: dsName}, callback

  @findOneById: (id, shortName, callback) ->
    DbDataset.findOne {_id: id, user: shortName}, callback
      
module.exports = Dataset
