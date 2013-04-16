request = require 'request'

boxMaxSize = (name) ->
  if name == 'grandfather'
    return 8000 # 8GB
  else if name == 'free'
    return 8 # 8MB
  else
    console.warn 'planSize: unknown plan', name
    return 8

setDiskQuota = (box, accountLevel, cb) ->
  quotaServer = process.env.CU_QUOTA_SERVER
  unless quotaServer? and quotaServer.length > 0
    return cb(null, true) unless process.env.CU_QUOTA_SERVER?
  maxSize = boxMaxSize accountLevel
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

exports.boxMaxSize = boxMaxSize
exports.setDiskQuota = setDiskQuota
