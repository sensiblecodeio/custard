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

  gitClone: (options, callback) ->
    @directory = "#{options.dir}/#{@name}"
    child_process.exec "git clone #{@gitUrl} #{@directory}", callback

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
    @dbClass.findOne {_id: id}, callback

module.exports = (dbObj) ->
  Tool.dbClass = zDbTool = dbObj if dbObj?
  Tool
