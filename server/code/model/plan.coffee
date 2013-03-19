request = require 'request'

datasetMaxSize = (name) ->
  if name == "grandfather"
    return 8000 # 8GB
  else if name == "free"
    return 8 # 8MB
  else
    console.warn "planSize: unknown plan", name
    return 8

setDiskQuota = (dataset, accountLevel, cb) ->
  maxSize = datasetMaxSize accountLevel
  request.post
    uri: "#{process.env.CU_QUOTA_SERVER}/quota"
    form:
      path: dataset.box
      size: maxSize
  , (err, res, body) ->
    if err
      console.log("failed to setDiskQuota for", dataset.box)
      cb err
    cb null, true

exports.datasetMaxSize = datasetMaxSize
exports.setDiskQuota = setDiskQuota
