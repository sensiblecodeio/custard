request = require 'request'

boxMaxSize = (name) ->
  if name == "grandfather"
    return 8000 # 8GB
  else if name == "free"
    return 8 # 8MB
  else
    console.warn "planSize: unknown plan", name
    return 8

setDiskQuota = (box, accountLevel, cb) ->
  maxSize = boxMaxSize accountLevel
  request.post
    uri: "#{process.env.CU_QUOTA_SERVER}/quota"
    form:
      path: box.name
      size: maxSize
  , (err, res, body) ->
    if err
      console.log("failed to setDiskQuota for", box.name)
      cb err
    cb null, true

exports.boxMaxSize = boxMaxSize
exports.setDiskQuota = setDiskQuota
