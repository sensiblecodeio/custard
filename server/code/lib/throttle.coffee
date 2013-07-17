_ = require 'underscore'

callNext = (next) ->
  next()

exports.throttle = (getIdentifier, timeout = 1000) ->
  cache = {}
  throttleInner = (req, resp, next) ->
    identifier = getIdentifier(arguments)

    unless identifier of cache
      cache[identifier] = _.throttle(callNext, timeout, {trailing: false})

    cache[identifier](next)

  return throttleInner
