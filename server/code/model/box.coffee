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

getGitURL = (tool, server) ->
  # :todo: Maybe use a different server for dev.scraperwiki.com
  if /dev/.test server
    origin = "https://git.scraperwiki.com"
  else
    origin = "https://git.scraperwiki.com"

  url = "#{origin}/#{tool.name}/.git"
  return url


class Box extends ModelBase
  @dbClass: zDbBox

  installTool: (arg, callback) ->
    Tool.findOneByName arg.toolName, (err, tool) =>
      if err?
        callback "Can't find tool"
      else
        # EG: https://git.scraperwiki.com/tool-name
        # :todo: When we have paid-for tools (private), then
        # the https server will need to authenticate each box
        # to check it has access to the git repo. It can do this
        # (in principle) using ident-express.
        gitURL = getGitURL(tool, @server)
        _exec
          user: arg.user
          boxName: @name
          boxServer: @server
          cmd: "rm -fr http && git clone #{gitURL} tool && ln -s tool/http http"
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
