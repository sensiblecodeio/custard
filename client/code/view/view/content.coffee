class Cu.View.ViewContent extends Backbone.View
  id: 'fullscreen'

  showContent: ->
    @boxUrl = @model.endpoint()
    @settings (settings) =>
      frag = encodeURIComponent JSON.stringify(settings)
      @setupEasyXdm "#{@boxUrl}/#{@model.get 'box'}/#{settings.source.publishToken}/container.html##{frag}"

  render: ->
    $('body').addClass('fullscreen')

  close: ->
    $('body').removeClass('fullscreen')
    super()

  setupEasyXdm: (url) ->
    transport = new easyXDM.Rpc
      remote: url
      container: document.getElementById('fullscreen')
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
          app.tools().fetch
            success: ->
              mod = Cu.Model.Dataset.findOrCreate box: box
              mod.fetch
                success: (model, resp, options) ->
                  model.set 'displayName', name
                  model.save()
        pushSQL: (query, toolName) =>
          # TODO: passing via a global variable is ickly
          window.app.pushSqlQuery = query

          app.tools().fetch
            error: (a, b, c) ->
              console.warn model, xhr, options
            success: (tools, resp, options) ->
              tool = app.tools().findByName toolName
              # TODO: DRY with tool tile install
              dataset = Cu.Model.Dataset.findOrCreate
                displayName: tool.get('manifest').displayName
                tool: tool

              dataset.new = true

              dataset.save {},
                wait: true
                success: ->
                  delete dataset.new
                  window.app.navigate "/dataset/#{dataset.id}/settings", {trigger: true}
                error: (model, xhr, options) ->
                  console.warn "Error creating dataset (xhr status: #{xhr.status} #{xhr.statusText})"

class Cu.View.AppContent extends Cu.View.ViewContent
  settings: (callback) ->
    query = window.app.pushSqlQuery
    window.app.pushSqlQuery = null
    publishToken = @model.get('boxJSON')?.publish_token
    callback
      source:
        apikey: window.user.effective.apiKey
        url: "#{@boxUrl}/#{@model.get 'box'}/#{publishToken}"
        publishToken: publishToken
        box: @model.get 'box'
        sqlQuery: query

class Cu.View.PluginContent extends Cu.View.ViewContent
  settings: (callback) ->
    query = window.app.pushSqlQuery
    window.app.pushSqlQuery = null
    dataset = @model.get 'plugsInTo'
    viewToken = @model.get('boxJSON')?.publish_token
    datasetToken = dataset.get('boxJSON')?.publish_token
    displayName = dataset.get('displayName')
    callback
      source:
        apikey: window.user.effective.apiKey
        url: "#{@boxUrl}/#{@model.get 'box'}/#{viewToken}"
        publishToken: viewToken
        box: @model.get 'box'
        sqlQuery: query
      target:
        url: "#{@boxUrl}/#{dataset.get 'box'}/#{datasetToken}"
        publishToken: datasetToken
        box: dataset.get 'box'
        displayName: displayName
