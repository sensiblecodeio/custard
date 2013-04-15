request = require 'request'
xml2js = require 'xml2js'

class exports.Subscription
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
