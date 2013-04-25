request = require 'request'
plans = require 'plans.json'

setDiskQuota = (box, accountLevel, cb) ->
  quotaServer = process.env.CU_QUOTA_SERVER
  unless quotaServer? and quotaServer.length > 0
    return cb(null, true)
  maxSize = plans[accountLevel]?.maxDiskSpaceMB or 8
  request.post
    uri: "#{quotaServer}/quota"
    form:
      path: box.name
      size: maxSize
  , (err, res, body) ->
    if err?
      console.warn 'failed to setDiskQuota for', box.name
      cb err
    cb null, true

exports.setDiskQuota = setDiskQuota
