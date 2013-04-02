mongoose = require 'mongoose'
async = require 'async'
nibbler = require 'nibbler'
request = require 'request'

Schema = mongoose.Schema

ModelBase = require 'model/base'
{Tool} = require 'model/tool'

boxSchema = new Schema
  users: [String]
  name:
    type: String
    index: unique: true
  # maybe host here?

zDbBox = mongoose.model 'Box', boxSchema

_exec = (arg, callback) ->
  request.post
    uri: "#{process.env.CU_BOX_SERVER}/#{arg.boxName}/exec"
    form:
      apikey: arg.user.apiKey
      cmd: arg.cmd
  , callback

class Box extends ModelBase
  @dbClass: zDbBox

  installTool: (arg, callback) ->
    Tool.findOneByName arg.toolName, (err, tool) =>
      if err?
        callback "Can't find tool"
      else
        _exec
          user: arg.user
          boxName: @name
          cmd: "rm -r http && git clone #{tool.gitUrl} tool --depth 1 && ln -s tool/http http"
        , (err, res, body) ->
          if err?
            callback err
          else if res.statusCode isnt 200
            callback {statusCode: res.statusCode, body: body}
          else
            callback null

  @findAllByUser: (shortName, callback) ->
    @dbClass.find users: shortName, callback

  @findOneByName: (boxName, callback) ->
    @dbClass.findOne name: boxName, callback

  @findUsersByName: (boxName, callback) ->
    @findOneByName boxName, (err, box) ->
      callback err, box?.users

  @create: (user, callback) ->
    boxName = @_generateBoxName()
    request.post
      uri: "#{process.env.CU_BOX_SERVER}/box/#{boxName}"
      form:
        apikey: user.apiKey
    , (err, res, body) ->
      # TODO: we don't need multiple users
      box = new Box({users: [user.shortName], name: boxName})
      box.save (err) ->
        if err?
          callback err, null
        else if res.statusCode isnt 200
          callback {statusCode: res.statusCode, body: body}, null
        else
          callback null, box

  @_generateBoxName: ->
    r = Math.random() * Math.pow(10,9)
    return nibbler.b32encode(String.fromCharCode(r>>24,(r>>16)&0xff,(r>>8)&0xff,r&0xff)).replace(/[=]/g,'').toLowerCase()

exports.Box = Box

exports.dbInject = (dbObj) ->
  Box.dbClass = zDbBox = dbObj
  Box
