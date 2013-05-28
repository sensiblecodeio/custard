#!/usr/bin/env coffee
# Migrates a single box to a server. Run on server that box is to be
# migrated to.
{exec} = require 'child_process'

mongoose = require 'mongoose'
async = require 'async'
request = require 'request'

{User} = require 'model/user'
{Box} = require 'model/box'

BOX_NAME = process.argv[2]
NEW_BOX_SERVER = process.argv[3]

boxExec = (cmd, box, user, callback) ->
  request.post
    uri: "#{Box.endpoint box.server, box.name}/exec"
    form:
      apikey: user.apikey
      cmd: cmd
  , callback

unless BOX_NAME? or NEW_BOX_SERVER?
  console.log "./script <box name> <new box server>"
  process.exit 1

mongoose.connect process.env.CU_DB

migratePasswdEntry = (box, user, callback) ->
  # TODO: Add UID to box in DB
  console.log "Migrating passwd entry..."
  boxExec "id -u", box, user, (err, res, uid) ->
    uid = uid.replace('\n', '')
    exec "util/addUnixUser.sh #{box.name} #{uid}", (err, stdout, stderr) ->
      console.log "migratePasswdEntry", err, stdout, stderr
      callback()

transferBoxData = (callback) ->
  # Run duplicity to get latest backed up data??
  console.log "Transferring box data..."
  exec "util/transferBoxData.sh #{box.name}", (err, stdout, stderr) ->
    console.log "transferBoxData", err, stdout, stderr
    return callback()

transferCrontab = (callback) ->
  console.log "Transferring crontab..."
  # Save existing crontab (exec crontab) to crontab file, chown, crontab < crontab
  return callback()

disableOldCrontab = (callback) ->
  console.log "Disabling old crontab"
  # Exec crontab -r
  return callback()

Box.findOneByName BOX_NAME, (err, box) ->
  User.findByShortName box.users[0], (err, user) ->
    migratePasswdEntry box, user, ->
      transferBoxData ->
        transferCrontab ->
          disableOldCrontab ->
            box.server = NEW_BOX_SERVER
            box.save (err) ->
              box.distributeSSHKeys (err, res, body) ->
                console.log 'distrib', err, res, body
