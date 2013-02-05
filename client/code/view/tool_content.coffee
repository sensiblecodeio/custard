class Cu.View.ToolContent extends Backbone.View
  id: 'fullscreen'

  initialize: ->
    boxUrl = window.boxServer
    @model.publishToken (token) =>
      obj =
        source:
          apikey: window.user.effective.apiKey
          url: "#{boxUrl}/#{@model.get 'box'}/#{token}"

      frag = encodeURIComponent JSON.stringify(obj)
      @setupEasyXdm "#{boxUrl}/#{@model.get 'box'}/#{token}/http/##{frag}"

  setupEasyXdm: (url) ->
    transport = new easyXDM.Rpc
      remote: url
      container: 'fullscreen'
    ,
      local:
        redirect: (url) ->
          window.app.navigate url, trigger: true
        getURL: (cb) ->
          cb window.location.href

