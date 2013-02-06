class Cu.View.ToolContent extends Backbone.View
  id: 'fullscreen'
  boxUrl: window.boxServer

  initialize: ->
    @settings (settings) =>
      frag = encodeURIComponent JSON.stringify(settings)
      @setupEasyXdm "#{@boxUrl}/#{@model.get 'box'}/#{settings.source.token}/container.html##{frag}"

  setupEasyXdm: (url) ->
    transport = new easyXDM.Rpc
      remote: url
      container: 'fullscreen'
    ,
      local:
        redirect: (url) ->
          isExternal = new RegExp('https?://')
          if isExternal.test url
            location.href = url
          else
            window.app.navigate url, trigger: true
        getURL: (cb) ->
          cb window.location.href

class Cu.View.AppContent extends Cu.View.ToolContent
  settings: (callback) ->
    @model.publishToken (token) =>
      callback
        source:
          apikey: window.user.effective.apiKey
          url: "#{@boxUrl}/#{@model.get 'box'}/#{token}"
          token: token

class Cu.View.PluginContent extends Cu.View.ToolContent
  settings: (callback) ->
    @model.publishToken (view_token) =>
      dataset = @model.get 'plugsInTo'
      dataset.publishToken (dataset_token) =>
        callback
          source:
            apikey: window.user.effective.apiKey
            url: "#{@boxUrl}/#{@model.get 'box'}/#{view_token}"
            token: view_token
          target:
            url: "#{@boxUrl}/#{dataset.get 'box'}/#{dataset_token}"
            token: dataset_token
