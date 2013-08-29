_ = require 'underscore'
mongoose = require 'mongoose'
async = require 'async'
nibbler = require 'nibbler'
request = require 'request'

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
        callback "Can't find tool"
      else if not tool?
        callback "You don't seem to have permission to install this"
      else
        # EG: https://git.scraperwiki.com/tool-name
        # :todo: When we have paid-for tools (private), then
        # the https server will need to authenticate each box
        # to check it has access to the git repo. It can do this
        # (in principle) using ident-express.
        gitURL = getGitURL(tool, @server)
        toolsDir = process.env.CU_TOOLS_DIR
        # Clone from gitURL if it doesn't exist in the tool cache
        tool.gitCloneIfNotExists dir: toolsDir, (err) =>
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

  distributeSSHKeys: (callback) ->
    {User} = require 'model/user'
    boxKeys = []
    User.findByShortName @users[0], (err, user) =>
      boxKeys = boxKeys.concat user.sshKeys
      request.post
        uri: "#{@endpoint()}/sshkeys"
        form:
          keys: JSON.stringify boxKeys
      , callback

  endpoint: () ->
    Box.endpoint @server, @name

  save: (callback) ->
    unless @uid?
      @uid = Box.generateUid()
    super (err) =>
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
      proto_server = "http://#{process.env.CU_BOX_SERVER}"
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

    box.save (err) ->
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
        box.boxJSON = JSON.parse body
        box.save (err) ->
          if err?
            callback err, null
          else if res.statusCode isnt 200
            callback {statusCode: res.statusCode, body: body}, null
          else
            Plan.setDiskQuota box, user.accountLevel, (err) ->
              console.warn "setDiskQuota on #{box.name} error: #{err}"
            callback null, box

  @_generateBoxName: ->
    r = Math.random() * Math.pow(10,9)
    return nibbler.b32encode(String.fromCharCode(r>>24,(r>>16)&0xff,(r>>8)&0xff,r&0xff)).replace(/[=]/g,'').toLowerCase()

  @generateUid: ->
    max = 429496729
    min = 4000
    Math.floor(Math.random() * (max - min + 1)) + min

  @listServers: ->
    if /staging/.test process.env.NODE_ENV
      return [process.env.CU_BOX_SERVER]
    _.uniq (obj.boxServer for plan, obj of plans)


exports.Box = Box

exports.dbInject = (dbObj) ->
  Box.dbClass = zDbBox = dbObj
  Box
