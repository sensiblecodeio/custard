_ = require 'underscore'
request = require 'request'
plans = require 'plans.json'

class exports.Plan
  @getPlan: (planName) ->
    plan = plans[planName]
    if not plan?
      return ["Plan #{planName} not found", null]
    else
      if process.env.CU_BOX_SERVER
        plan = _.clone(plan)
        plan.boxServer = process.env.CU_BOX_SERVER
      return [null, plan]
