crypto = require 'crypto'
qs = require 'qs'

toNestedQuerystring = (obj) ->
  qs.stringify(obj)

exports.sign = (data) ->
  unless process.env.RECURLY_PRIVATE_KEY?
    throw {error: 'Recurly.js private key is not set.'}
  if 'timestamp' not in data
    data.timestamp = Math.round (Date.now() / 1000)
  if 'nonce' not in data
    randomBytes = crypto.randomBytes 32
    randomString = Buffer(randomBytes).toString 'base64'
    data.nonce = randomString.replace /\W+/g, ''

  unsigned = toNestedQuerystring data
  hmac = crypto.createHmac('sha1', process.env.RECURLY_PRIVATE_KEY)
  signed = hmac.update(unsigned).digest('hex')
  return [signed, unsigned].join '|'
