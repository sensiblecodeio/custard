child_process = require 'child_process'
fs = require 'fs'
exists = fs.exists or path.exists

async = require 'async'
request = require 'request'
rimraf = require 'rimraf'

mongoose = require 'mongoose'
Schema = mongoose.Schema

{Dataset} = require 'model/dataset'

ModelBase = require 'model/base'

toolSchema = new Schema
  name:
    type: String
    index: unique: true
  user: String
  type: String
  gitUrl: String
  public: {type: Boolean, default: false}
  allowedUsers: [String]
  manifest: Schema.Types.Mixed
  created:
    type: Date
    default: Date.now
  updated: Date

zDbTool = mongoose.model 'Tool', toolSchema

class exports.Tool extends ModelBase
  @dbClass: zDbTool

  rsync: (boxServer, callback) =>
    if 'testing' == process.env.NODE_ENV
      callback()
    else
      child_process.exec "run-this-one rsync --delete -avz -e 'ssh -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no -i /etc/custard/tools_rsa' /opt/tools/ tools@#{boxServer}:", callback

  gitCloneOrPull: (options, callback) ->
    {Box} = require 'model/box'
    @directory = "#{options.dir}/#{@name}"
    # :todo: whitelist @directory
    fs.exists @directory, (exists) =>
      if not exists
        cmd = "mkdir #{@directory}; cd #{@directory}; git init; git fetch #{@gitUrl}; git checkout FETCH_HEAD"
      else
        cmd = "cd #{@directory}; git fetch #{@gitUrl}; git checkout FETCH_HEAD"
      child_process.exec cmd, =>
        async.each Box.listServers(), @rsync, callback


  # TODO: DRY
  # This is only used in the edge case where the tool is in the custard DB,
  # but not on the custard server
  gitCloneIfNotExists: (options, callback) ->
    {Box} = require 'model/box'
    @directory = "#{options.dir}/#{@name}"
    # :todo: whitelist @directory
    fs.exists @directory, (exists) =>
      if not exists
        cmd = "mkdir #{@directory}; cd #{@directory}; git init; git fetch #{@gitUrl}"
        child_process.exec cmd, =>
          async.each Box.listServers(), @rsync, callback
      else
        callback null, null

  loadManifest: (callback) ->
    fs.exists @directory, (isok) =>
      if not isok
        callback 'not cloned'
        return
      fs.readFile "#{@directory}/scraperwiki.json", (err, data) =>
        if err
          callback err
          return
        try
          @manifest = JSON.parse data
        catch error
          callback error: json: error
        callback null

  deleteRepo: (callback) ->
    rimraf @directory, callback

  save: (callback) ->
    @updated = Date.now()
    super callback

  @findOneById: (id, callback) ->
    @dbClass.findOne {_id: id}, (err, doc) =>
      if doc is null
        callback err, null
      else
        callback null, @makeModelFromMongo doc

  @findOneByName: (name, callback) ->
    @dbClass.findOne {name: name}, (err, doc) =>
      if doc is null
        callback err, null
      else
        callback null, @makeModelFromMongo doc

  @findOneForUser: (args, callback) ->
    @dbClass.findOne
      name: args.name
      $or: [
        {user: args.user.shortName}
        {public: true}
        allowedUsers: { $in:  [args.user.shortName] }
      ]
    , (err, doc) =>
      if doc is null
        callback err, null
      else
        callback null, @makeModelFromMongo doc

  @findForUser: (shortName, cb) ->
    @dbClass.find $or: [{user: shortName}, {public: true}, {allowedUsers: { $in:  [shortName]}}], (err, docs) =>
      if docs is null
        cb err, null
      else
        result = (@makeModelFromMongo(doc) for doc in docs)
        cb null, result

exports.dbInject = (dbObj) ->
  Tool.dbClass = zDbBox = dbObj
  Tool
