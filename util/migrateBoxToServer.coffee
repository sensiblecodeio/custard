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

boxExec = (cmd, box, user, callback) ->
  request.post
    uri: "#{Box.endpoint box.server, box.name}/exec"
    form:
      apikey: user.apikey
      cmd: cmd
  , callback

unless BOX_NAME?
  console.log "You must specify a box name"
  process.exit 1

mongoose.connect process.env.CU_DB

migratePasswdEntry = (box, user, callback) ->
  # Add UID to box in DB
  boxExec "id -u", box, user, (err, res, uid) ->
    uid = uid.replace('\n', '')
    exec "util/addUnixUser.sh #{box.name} #{uid}", (err, stdout, stderr) ->
      console.log "migratePasswdEntry", err, stdout, stderr
      callback()

# Force cobalt to distribute SSH keys (steal code from custard?) 1
# Refactor distributeUserKeys to allow for update of single box
#
# Transfer box data (duplicity from backups + rsync) 1
# Run duplicity to get latest backed up data??
#
# Cronfiles (scp) 1
# Save existing crontab (exec crontab) to crontab file, chown, crontab < crontab
#
# Disable cronjob on existing server 1
# Exec crontab -r

Box.findOneByName BOX_NAME, (err, box) ->
  User.findByShortName box.users[0], (err, user) ->
    migratePasswdEntry box, user, ->
      console.log "Migrated passwd entry"
