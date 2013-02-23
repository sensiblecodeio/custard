class Cu.View.ViewContent extends Backbone.View
  id: 'fullscreen'
  boxUrl: window.boxServer

  initialize: ->
    $('body').addClass('fullscreen')
    @settings (settings) =>
      frag = encodeURIComponent JSON.stringify(settings)
      @setupEasyXdm "#{@boxUrl}/#{@model.get 'box'}/#{settings.source.publishToken}/container.html##{frag}"

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
        rename: (box, name) ->
          mod = Cu.Model.Dataset.findOrCreate box: box
          mod.fetch
            success: (model, resp, options) ->
              model.set 'displayName', name
              model.save()

  close: ->
    $('body').removeClass('fullscreen')
    super()

class Cu.View.AppContent extends Cu.View.ViewContent
  settings: (callback) ->
    @model.publishToken (publishToken) =>
      callback
        source:
          apikey: window.user.effective.apiKey
          url: "#{@boxUrl}/#{@model.get 'box'}/#{publishToken}"
          publishToken: publishToken
          box: @model.get 'box'

class Cu.View.PluginContent extends Cu.View.ViewContent
  settings: (callback) ->
    @model.publishToken (viewToken) =>
      dataset = @model.get 'plugsInTo'
      dataset.publishToken (datasetToken) =>
        callback
          source:
            apikey: window.user.effective.apiKey
            url: "#{@boxUrl}/#{@model.get 'box'}/#{viewToken}"
            publishToken: viewToken
            box: @model.get 'box'
          target:
            url: "#{@boxUrl}/#{dataset.get 'box'}/#{datasetToken}"
            publishToken: datasetToken
            box: dataset.get 'box'
