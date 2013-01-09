mongoose = require 'mongoose'
Schema = mongoose.Schema

toolSchema = new Schema
  name: String
  type: String
  gitUrl: String
  manifest: Schema.Types.Mixed

DbTool = mongoose.model 'Tool', toolSchema

class Tool
  constructor: (obj) ->
    for k of obj
      @[k] = obj[k]
    @

  save: (done) ->
    ds = new DbTool
      name: @name
      type: @type
      gitUrl: @gitUrl
      manifest: @manifest

    ds.save =>
      @id = ds._id
      done()

  @findAll: (callback) ->
    DbTool.find {}, callback
  
  @findOneById: (id, callback) ->
    DbTool.findOne {_id: id}, callback

module.exports = (dbObj) ->
  DbTool = dbObj if dbObj?
  Tool
