#!/usr/bin/env coffee
# Migrates a single box to a server. Run on server that box is to be
# migrated to.
fs = require 'fs'
{exec} = require 'child_process'

mongoose = require 'mongoose'
async = require 'async'
request = require 'request'
mkdirp = require 'mkdirp'

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

transferBoxData = (box, user, callback) ->
  # Run duplicity to get latest backed up data??
  console.log "Transferring box data..."
  exec "util/transferBoxData.sh #{box.name} #{box.server}", (err, stdout, stderr) ->
    console.log "transferBoxData", err, stdout, stderr
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
        console.log "chown", err, stdout, stderr

        exec "chmod 600 #{crontabPath}", (err, stdout, stderr) ->
          console.log "chmod", err, stdout, stderr
          return callback()


disableOldCrontab = (box, user, callback) ->
  console.log "Disabling old crontab..."
  boxExec "crontab -r", box, user, (err, res, body) ->
    console.log "disableOldCrontab", err, body
    return callback()

Box.findOneByName BOX_NAME, (err, box) ->
  box = Box.makeModelFromMongo box
  User.findByShortName box.users[0], (err, user) ->
    migratePasswdEntry box, user, ->
      transferBoxData box, user, ->
        transferCrontab box, user, ->
          disableOldCrontab box, user, ->
            box.server = NEW_BOX_SERVER
            process.env.CU_BOX_SERVER = NEW_BOX_SERVER
            mkdirp.sync "/opt/cobalt/etc/sshkeys/#{box.name}"
            box.save (err) ->
              box.distributeSSHKeys (err, res, body) ->
                console.log 'distributeSSHKeys', err, body
                process.exit()
