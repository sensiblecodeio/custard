_ = require 'underscore'
mongoose = require 'mongoose'
async = require 'async'
request = require 'request'
randtoken = require 'rand-token'

Schema = mongoose.Schema

ModelBase = require 'model/base'
{Tool} = require 'model/tool'
{Plan} = require 'model/plan'
plans = require 'plans.json'

boxSchema = new Schema
  users: [String]
  name:
    type: String
    index: unique: true
  server: String
  boxJSON: Schema.Types.Mixed
  uid:
    type: Number
    index: unique: true

zDbBox = mongoose.model 'Box', boxSchema

_exec = (arg, callback) ->
  request.post
    uri: "#{Box.endpoint arg.boxServer, arg.boxName}/exec"
    form:
      apikey: arg.user.apiKey
      cmd: arg.cmd
  , callback

getGitURL = (tool, server) ->
  if process.env.NODE_ENV is 'production'
    return "git://git.scraperwiki.net/#{tool.name}"
  else
    return tool.gitUrl

class Box extends ModelBase
  @dbClass: zDbBox
  duplicateErrorCount: 0

  installTool: (arg, callback) ->
    Tool.findOneForUser {name: arg.toolName, user: arg.user}, (err, tool) =>
      if err?
        return callback "Can't find tool"
      if not tool?
        return callback "You don't seem to have permission to install this"

      # EG: https://git.scraperwiki.com/tool-name
      # :todo: When we have paid-for tools (private), then
      # the https server will need to authenticate each box
      # to check it has access to the git repo. It can do this
      # (in principle) using ident-express.
      gitURL = getGitURL(tool, @server)
      toolsDir = process.env.CU_TOOLS_DIR

      _exec
        user: arg.user
        boxName: @name
        boxServer: @server
        cmd: "mkdir incoming http; ln -s /tools/#{tool.name} tool"
      , (err, res, body) ->
        if err?
          callback err
        else if res.statusCode isnt 200
          callback {statusCode: res.statusCode, body: body}
        else
          callback null

  endpoint: () ->
    Box.endpoint @server, @name

  save: (callback) ->
    unless @uid?
      @uid = Box.generateUid()
    super (err) =>
      console.log "Saving box", @name, "uid", @uid, "errors:", err?.code, err
      if err? and err.code is 11000
        if @duplicateErrorCount <3
          @uid = Box.generateUid()
          @save callback
          @duplicateErrorCount += 1
        else
          callback err
      else callback err

  @endpoint: (server, name) ->
    proto_server = "https://#{server}"
    if process.env.CU_BOX_SERVER
      proto_server = "https://#{process.env.CU_BOX_SERVER}"
    return "#{proto_server}/#{name}"

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

    console.log "server #{server} boxName #{boxName}"

    # TODO: we don't need multiple users
    box = new Box
      users: [user.shortName]
      name: boxName
      server: server
      boxJSON:
        publish_token: randtoken.generate(15).toLowerCase()

    box.save (err) ->
      if err?
        return callback err, null
        
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
          uid: box.uid
      , (err, res, body) ->
        if err?
          return callback err, null
        if res.statusCode != 200
          return callback body, null
        callback null, box

  @_generateBoxName: ->
    return randtoken.generate(7).toLowerCase()

  @generateUid: ->
    max = 429496729
    min = 4000
    Math.floor(Math.random() * (max - min + 1)) + min

  @listServers: ->
    if /testing|staging/.test process.env.NODE_ENV
      console.log "process.env.CU_BOX_SERVER", process.env.CU_BOX_SERVER
      return [process.env.CU_BOX_SERVER]
    _.uniq (obj.boxServer for plan, obj of plans)


exports.Box = Box

exports.dbInject = (dbObj) ->
  Box.dbClass = zDbBox = dbObj
  Box
