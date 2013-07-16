_ = require 'underscore'
      
exports.throttle = (getIdentifier, timeout = 1000) ->
  cache = {}
  throttleInner = (req, resp, next) ->
    identifier = getIdentifier(arguments)

    unless identifier of cache
       cache[identifier] = _.throttle(next, timeout, {trailing: false})

    cache[identifier]()

  return throttleInner
