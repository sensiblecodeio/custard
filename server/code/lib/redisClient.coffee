redis = require 'redis'

class exports.RedisClient
  @client: redis.createClient 6379, process.env.REDIS_SERVER

  if /production|staging/.test process.env.NODE_ENV
    Dataset.redisClient.auth process.env.REDIS_PASSWORD, (err) ->
      if err?
        console.warn 'Redis auth error: ', err
