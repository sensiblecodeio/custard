_ = require 'underscore'
request = require 'request'
plans = require 'plans.json'

class exports.Plan
  @setDiskQuota: (box, accountLevel, cb) ->
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

  @getPlan: (planName) ->
    plan = plans[planName]
    if not plan?
      return ["Plan #{planName} not found", null]
    else
      if process.env.CU_BOX_SERVER
        plan = _.clone(plan)
        plan.boxServer = process.env.CU_BOX_SERVER
      return [null, plan]
