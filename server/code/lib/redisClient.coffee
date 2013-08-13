redis = require 'redis'
_ = require 'underscore'

# Time in milliseconds to wait before submitting
# expensive endpoint requests so that they can be
# de-duplicated
DEBOUNCE_PERIOD = 1000

# Return a memoized debounce function, keyed on the box,
# which lasts as long as the debounce period.
getDebouncedCache = {}
getDebounced = (key, f) =>
  if not getDebouncedCache[key]
    getDebouncedCache[key] = _.debounce =>
      result = f.apply null, arguments
      delete getDebouncedCache[key]
      return result
    , DEBOUNCE_PERIOD
  return getDebouncedCache[key]

class exports.RedisClient
  @client: {}

  unless /cron/.test process.env.NODE_ENV
    @client = redis.createClient 6379, process.env.REDIS_SERVER

  if /production|staging/.test process.env.NODE_ENV
    @client.auth process.env.REDIS_PASSWORD, (err) ->
      if err?
        console.warn 'Redis auth error: ', err

  @debouncedPublish: (key, channel, message) ->
    publish = getDebounced key, ->
      RedisClient.client.publish.apply RedisClient.client, arguments
    publish channel, message
