child_process = require 'child_process'
fs = require 'fs'
exists = fs.exists or path.exists
rimraf = require 'rimraf'

mongoose = require 'mongoose'
Schema = mongoose.Schema

ModelBase = require 'model/base'

toolSchema = new Schema
  name:
    type: String
    index: unique: true
  type: String
  gitUrl: String
  manifest: Schema.Types.Mixed

zDbTool = mongoose.model 'Tool', toolSchema

class Tool extends ModelBase
  @dbClass: zDbTool

  gitCloneOrPull: (options, callback) ->
    @directory = "#{options.dir}/#{@name}"
    fs.exists @directory, (exists) =>
      if not exists
        cmd = "git clone #{@gitUrl} #{@directory}"
      else
        cmd = "cd #{@directory}; git pull"
      child_process.exec cmd, callback

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

module.exports = (dbObj) ->
  Tool.dbClass = zDbTool = dbObj if dbObj?
  Tool
