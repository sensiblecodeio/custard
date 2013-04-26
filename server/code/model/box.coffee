mongoose = require 'mongoose'
async = require 'async'
nibbler = require 'nibbler'
request = require 'request'

Schema = mongoose.Schema

ModelBase = require 'model/base'
{Tool} = require 'model/tool'
{Plan} = require 'model/plan'

boxSchema = new Schema
  users: [String]
  name:
    type: String
    index: unique: true
  server: String
  boxJSON: Schema.Types.Mixed

zDbBox = mongoose.model 'Box', boxSchema

_exec = (arg, callback) ->
  request.post
    uri: "#{Box.endpoint arg.boxServer, arg.boxName}/exec"
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
          boxServer: @boxServer
          cmd: "rm -r http && git clone #{tool.gitUrl} tool --depth 1 && ln -s tool/http http"
        , (err, res, body) ->
          if err?
            callback err
          else if res.statusCode isnt 200
            callback {statusCode: res.statusCode, body: body}
          else
            callback null

  @endpoint: (server, name) ->
    proto_server = "https://#{server}"
    if process.env.CU_BOX_SERVER?
      proto_server = "http://#{process.env.CU_BOX_SERVER}"
    return "#{proto_server}/#{name}"

  endpoint: () ->
    Box.endpoint @server, @name

  @findAllByUser: (shortName, callback) ->
    @dbClass.find users: shortName, callback

  @findOneByName: (boxName, callback) ->
    @dbClass.findOne name: boxName, callback

  @findUsersByName: (boxName, callback) ->
    @findOneByName boxName, (err, box) ->
      callback err, box?.users

  @create: (user, callback) ->
    boxName = @_generateBoxName()
    [err_, plan] = Plan.getPlan user.accountLevel
    server = plan?.boxServer
    if not server
      return callback
        statusCode: 500
        body: JSON.stringify(error: "Plan/Server not present")
      , null
    # The URI we need should have "box" between the server name and the
    # box name. Bit tricky to do. :todo: make better (by fixing cobalt?).
    uri = "#{Box.endpoint server, boxName}"
    uri = uri.split '/'
    # Insert 'box' just after 3rd element.
    uri.splice 3, 0, 'box'
    uri = uri.join '/'
    console.log "BOX CREATE posting to #{uri}"
    request.post
      uri: uri
      form:
        apikey: user.apiKey
    , (err, res, body) ->
      console.log "server #{server} boxName #{boxName}"

      if err?
        return callback err, null
      # TODO: we don't need multiple users
      boxJSON = JSON.parse body
      box = new Box({users: [user.shortName], name: boxName, server: server, boxJSON: boxJSON})
      box.save (err) ->
        if err?
          callback err, null
        else if res.statusCode isnt 200
          callback {statusCode: res.statusCode, body: body}, null
        else
          #TODO: background this
          Plan.setDiskQuota box, user.accountLevel, (err) ->
            callback null, box

  @_generateBoxName: ->
    r = Math.random() * Math.pow(10,9)
    return nibbler.b32encode(String.fromCharCode(r>>24,(r>>16)&0xff,(r>>8)&0xff,r&0xff)).replace(/[=]/g,'').toLowerCase()

exports.Box = Box

exports.dbInject = (dbObj) ->
  Box.dbClass = zDbBox = dbObj
  Box
