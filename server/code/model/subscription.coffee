request = require 'request'
xml2js = require 'xml2js'

class exports.Subscription
  constructor: (obj) ->
    for k of obj
      @[k] = obj[k]

  upgrade: (recurlyPlan, callback) ->
    request.put
      uri: "https://#{process.env.RECURLY_API_KEY}:@#{process.env.RECURLY_DOMAIN}.recurly.com/v2/subscriptions/#{@uuid}/"
      strictSSL: true
      headers:
        'Accept': 'application/xml'
        'Content-Type': 'application/xml; charset=utf-8'
      body: "<subscription><timeframe>now</timeframe><plan_code>#{recurlyPlan}</plan_code></subscription>"
    , (err, subResp, body) ->
      if err?
        return callback {error: err}, null
      else if subResp.statusCode isnt 200
        return callback { statusCode: subResp.statusCode, error: subResp.body }, null
      return callback null, subResp

  @getRecurlyResult: (token, callback) ->
    #TODO: check for valid plan code & recurlyAccount
    request.get
      uri: "https://#{process.env.RECURLY_API_KEY}:@api.recurly.com/v2/recurly_js/result/#{token}"
      strictSSL: true
      headers:
        'Accept': 'application/xml'
        'Content-Type': 'application/xml; charset=utf-8'
    , (err, recurlyResp, body) ->
      if err?
        callback {error: err}, null
      else if recurlyResp.statusCode isnt 200
        callback {statusCode: recurlyResp.statusCode, error: recurlyResp.body}, null
      else
        parser = new xml2js.Parser
          ignoreAttrs: true
          explicitArray: false
        parser.parseString recurlyResp.body, (err, obj) ->
          if err?
            callback {error: err}, null
          else
            callback null, obj
