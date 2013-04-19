_ = require 'underscore'
mongoose = require 'mongoose'
Schema = mongoose.Schema

ModelBase = require 'model/base'

viewSchema = new Schema
  box: String
  tool: String
  name: String
  displayName: String
  state: String

datasetSchema = new Schema
  box: String
  user: String  # Actually, the owner
  tool: String
  name: String
  displayName: String
  status: Schema.Types.Mixed
  state: String
  views: [viewSchema]

zDbDataset = mongoose.model 'Dataset', datasetSchema

class Dataset extends ModelBase
  @dbClass: zDbDataset

  validate: ->
    return 'no tool' unless @tool? and @tool.length > 0
    return 'no display name' unless @displayName? and @displayName.length > 0

  updateStatus: (status, callback) ->
    @status =
      type: status.type
      message: status.message
      updated: new Date()
    @status.type = 'ok' unless status.type in ['ok', 'error']
    @save callback

  @countVisibleDatasets: (user, callback) ->
    @dbClass.find({user: user, state: {$ne: 'deleted'}}).count callback

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

  @findAllByTool: (toolName, callback) ->
    @dbClass.find {tool: toolName, state: {$ne: 'deleted'}}, callback

Dataset.View =
  findAllByTool: (toolName, callback) ->
    Dataset.dbClass.find
      'views.tool': toolName
      state:
        $ne: 'deleted'
    , (err, docs) ->
      # convert from dataset to its views...
      listoflists = _.map docs, (item) ->
        newViews = []
        for view in item.views
          newView = user: item.user
          newViews.push _.extend newView, view.toObject()
        newViews
      # concatenate into one giant list...
      onelist = _.reduce listoflists, ((a, b) -> a.concat(b)), []
      # then filter.
      result = _.filter onelist, (item) ->
        item.tool is toolName
      callback null, result

exports.Dataset = Dataset

exports.dbInject = (dbObj) ->
  Dataset.dbClass = zDbDataset = dbObj
  Dataset
