_ = require 'underscore'
mongoose = require 'mongoose'
Schema = mongoose.Schema
request = require 'request'

ModelBase = require 'model/base'
RedisClient = require('lib/redisClient').RedisClient

viewSchema = new Schema
  box: String
  boxServer: String
  tool: String
  name: String
  displayName: String
  state: String
  boxJSON: Schema.Types.Mixed

datasetSchema = new Schema
  box: String
  boxServer: String
  user: String  # Actually, the owner
  tool: String
  name: String
  displayName: String
  status: Schema.Types.Mixed
  state: String
  views: [viewSchema]
  boxJSON: Schema.Types.Mixed
  createdDate: {type: Date}
  creatorShortName: String
  creatorDisplayName: String
  toBeDeleted: Date

zDbDataset = mongoose.model 'Dataset', datasetSchema

_exec = (arg, callback) ->
  {Box} = require 'model/box'
  request.post
    followAllRedirects: true
    uri: "#{Box.endpoint arg.boxServer, arg.boxName}/exec"
    form:
      apikey: arg.user.apikey
      cmd: arg.cmd
  , callback

class Dataset extends ModelBase
  @dbClass: zDbDataset

  validate: ->
    return 'no tool' unless @tool? and @tool.length > 0
    return 'no display name' unless @displayName? and @displayName.length > 0

  save: (callback) ->
    if @toBeDeleted?
      @toBeDeleted = new Date(@toBeDeleted)
    super callback

  updateStatus: (status, callback) ->
    @status =
      type: status.type
      message: status.message
      updated: new Date()
    @status.type = 'ok' unless status.type in ['ok', 'error']
    @save (err) =>
      boxes = _.map @views, (v) -> v.box
      message = JSON.stringify
        boxes: boxes
        type: @status.type
        message: @status.message
      env = process.env.NODE_ENV
      channel = "#{env}.cobalt.dataset.#{@box}.update"
      RedisClient.debouncedPublish @box, channel, message
      callback err

  cleanCrontab: (callback) ->
    {User} = require 'model/user'
    User.findByShortName @user, (err, user) =>
      _exec
        user: user
        boxName: @box
        boxServer: @boxServer
        cmd: "crontab -r"
      , (err, res, body) =>
        if err?
          callback err
        else if res.statusCode isnt 200
          callback {statusCode: res.statusCode, body: body}
        else
          @toBeDeleted = null
          @save callback

  @countVisibleDatasets: (user, callback) ->
    @dbClass.find({user: user, state: {$ne: 'deleted'}}).count callback

  @findAllByUserShortName: (name, callback) ->
    @dbClass.find {user: name, state: {$ne: 'deleted'}}, callback

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

  @findToBeDeleted: (callback) ->
    @find {state: 'deleted', toBeDeleted: {$lte: new Date()}}, callback

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

  changeBoxSever: (id, newServer, callback) ->
    Dataset.dbClass.findOne 'views.box': id, (err, dataset) ->
      if err?
        return callback err, null
      if dataset?
        view = _.find dataset.views, (view) -> view.box is id
        view.boxServer = newServer
        dataset.save callback
      else
        return callback "Unable to find box id "

exports.Dataset = Dataset

exports.dbInject = (dbObj) ->
  Dataset.dbClass = zDbDataset = dbObj
  Dataset
