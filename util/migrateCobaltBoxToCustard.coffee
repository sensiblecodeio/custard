#!/usr/bin/env coffee
fs = require 'fs'
{exec} = require 'child_process'
mongoose = require 'mongoose'
async = require 'async'
request = require 'request'
mkdirp = require 'mkdirp'

argv = require('optimist')
  .usage('Only for Linode->EC2 currently!\nUsage: $0 [--verbose] --source-box <box> --target-box <box> --source-host <host> --target-host <host>')
  .demand(['source-box', 'target-box', 'source-host', 'target-host'])
  .string(['source-box', 'target-box', 'source-host', 'target-host'])
  .alias('bs', 'source-box')
  .alias('v', 'verbose')
  .alias('bt', 'target-box')
  .alias('sh', 'source-host')
  .alias('th', 'target-host')
  .describe('source-box', "The box with the data you want to go into the new box")
  .describe('target-box', "The pre-existing target box whose data you want to replace")
  .describe('source-host', "Host where the box data is stored")
  .describe('target-host', "Specify the new box's hostname")
  .boolean('verbose')
  .argv

{Box} = require 'model/box'
{User} = require 'model/user'

SOURCE_BOX = argv['source-box']
TARGET_BOX = argv['target-box']
SOURCE_HOST = argv['source-host']
TARGET_HOST = argv['target-host']

process.env.CO_STORAGE_DIR?= ""

if not fs.existsSync "util"
  console.log "Should run script from top-level custard directory"
  process.exit 2

boxExec = (cmd, box, user, callback) ->
  request.post
    uri: "#{Box.endpoint box.server, box.name}/exec"
    form:
      apikey: user.apikey
      cmd: cmd
  , callback

checkVerboseAndPrint = (arg...) ->
  if argv.verbose
    console.log.apply this, arg

if not process.env.CU_DB
  console.log 'CU_DB variable not set.'
  process.exit 2
if not process.env.SSH_AUTH_SOCK
  console.log 'Need agent forwarding enabled'
if SOURCE_BOX?.length < 4
  console.log 'Specify source box'
if TARGET_BOX?.length < 4
  console.log 'Specify target box'

mongoose.connect process.env.CU_DB

rsyncData = (box, callback) ->
  cmd = "rsync --archive --verbose -e 'ssh' --rsync-path 'sudo rsync' /home/#{SOURCE_BOX}/ ubuntu@#{box.server}:/ebs/home/#{box.name}"
  exec cmd, (err, stdout, stderr) ->
    checkVerboseAndPrint cmd, err, stdout, stderr
    callback()

chownBox = (box, callback) ->
  cmd = "ssh ubuntu@#{box.server} 'sudo chown -R #{box.name}: /ebs/home/#{box.name}'"
  exec cmd, (err, stdout, stderr) ->
    checkVerboseAndPrint cmd, err, stdout, stderr
    callback()

copyCrontab = (box, callback) ->
  cmd = """cat /var/spool/cron/crontabs/#{SOURCE_BOX} | ssh ubuntu@#{box.server} 'sudo sh -c "cat > /ebs/crontabs/#{TARGET_BOX}; chown #{TARGET_BOX}:crontab /ebs/crontabs/#{TARGET_BOX}"'"""
  exec cmd, (err, stdout, stderr) ->
    checkVerboseAndPrint cmd, err, stdout, stderr
    callback()

Box.findOneByName TARGET_BOX, (err, box) ->
  unless box?.name?
    console.log "Target box #{TARGET_BOX} not found!"
    process.exit 4

  User.findByShortName box.users[0], (err, user) ->
    unless user?.apikey?
      console.log "User #{box.users[0]} not found!"
      process.exit 5

    rsyncData box, ->
      chownBox box, ->
        copyCrontab box, ->
          process.exit()
