#!/usr/bin/env coffee
# Migrates a single box to a server. Run on server that box is to be
# migrated to.
fs = require 'fs'
{exec} = require 'child_process'
mongoose = require 'mongoose'
async = require 'async'
request = require 'request'
mkdirp = require 'mkdirp'

argv = require('optimist')
  .usage('Usage: $0 [--verbose] --box <box> --host <host>')
  .demand(['box', 'host'])
  .alias('v', 'verbose')
  .alias('b', 'box')
  .alias('h', 'host')
  .describe('host', "Specify the new box's hostname")
  .boolean('verbose')
  .argv

{User} = require 'model/user'
{Box} = require 'model/box'
{Dataset} = require 'model/dataset'

BOX_NAME = argv.box
NEW_BOX_SERVER = argv.host

checkVerboseAndPrint = (arg...) ->
  if argv.verbose
    console.log.apply this, arg

boxExec = (cmd, box, user, callback) ->
  request.post
    uri: "#{Box.endpoint box.server, box.name}/exec"
    form:
      apikey: user.apikey
      cmd: cmd
  , callback

if not process.env.CU_DB
  console.log 'CU_DB variable not set.'
  process.exit 2

mongoose.connect process.env.CU_DB

migratePasswdEntry = (box, user, callback) ->
  # TODO: Add UID to box in DB
  console.log "Migrating passwd entry..."
  boxExec "id -u", box, user, (err, res, uid) ->
    uid = uid.replace('\n', '')
    exec "util/addUnixUser.sh #{box.name} #{uid}", (err, stdout, stderr) ->
      checkVerboseAndPrint "migratePasswdEntry", err, stdout, stderr
      callback()

transferSSHKeys = (box, user) ->
  box.server = NEW_BOX_SERVER
  process.env.CU_BOX_SERVER = NEW_BOX_SERVER
  mkdirp.sync "/opt/cobalt/etc/sshkeys/#{box.name}"
  box.save (err) ->
    box.distributeSSHKeys (err, res, body) ->
      checkVerboseAndPrint 'distributeSSHKeys', err, body
      Dataset.findOneById box.name, (err, dataset) ->
        if dataset?
          dataset.boxServer = NEW_BOX_SERVER
          dataset.save (err) ->
            checkVerboseAndPrint 'dataset save', err
            process.exit()
        else
          Dataset.View.changeBoxSever box.name, NEW_BOX_SERVER, (err) ->
              checkVerboseAndPrint "change view box server", err
              process.exit()

transferBoxData = (box, user, callback) ->
  # Run duplicity to get latest backed up data??
  console.log "Transferring box data..."
  exec "util/transferBoxData.sh #{box.name} #{box.server}", (err, stdout, stderr) ->
    checkVerboseAndPrint "transferBoxData", err, stdout, stderr
    return callback()

transferCrontab = (box, user, callback) ->
  console.log "Transferring crontab..."
  boxExec "crontab -l", box, user, (err, stdout, crontab) ->
    if /no crontab for/.test crontab
      console.log "No crontab"
      return callback()
    else
      crontabPath = "/var/spool/cron/crontabs/#{box.name}"
      fs.writeFileSync crontabPath, crontab
      exec "chown #{box.name}:crontab #{crontabPath}", (err, stdout, stderr) ->
        checkVerboseAndPrint "chown", err, stdout, stderr
        exec "chmod 600 #{crontabPath}", (err, stdout, stderr) ->
          checkVerboseAndPrint "chmod", err, stdout, stderr
          disableOldCrontab box, user, callback

disableOldCrontab = (box, user, callback) ->
  console.log "Disabling old crontab..."
  boxExec "crontab -r", box, user, (err, res, body) ->
    checkVerboseAndPrint "disableOldCrontab", err, body
    return callback()

Box.findOneByName BOX_NAME, (err, box) ->
  console.log "Migrating box #{box.name}"
  box = Box.makeModelFromMongo box
  User.findByShortName box.users[0], (err, user) ->
    migratePasswdEntry box, user, ->
      transferBoxData box, user, ->
        transferCrontab box, user, ->
          transferSSHKeys box, user ->
            process.exit()
