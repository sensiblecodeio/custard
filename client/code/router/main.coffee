num = String(Math.random()).replace '.',''


window.datasets = new Cu.Collection.DatasetList()
window.tools = new Cu.Collection.Tools()

Backbone.View::close = ->
  @off()
  @remove()

class Cu.Router.Main extends Backbone.Router

  initialize: ->
    @appView = new Cu.AppView '#content'
    @titleView = new Cu.AppView '#title'
    @navView ?= new Cu.View.Nav()

    # Move somewhere better
    $('#logo').click ->
      event.preventDefault()
      window.app.navigate "/", {trigger: true}

    # Backbone seems to reverse route order
    # TODO: revert to standard routes?
    @route RegExp('.*'), 'fourOhFour'
    @route RegExp('^/?$'), 'main'
    @route RegExp('tools/?'), 'tools'
    @route RegExp('tool/([^/]+)/?'), 'tool'
    @route RegExp('dataset/([^/]+)/?'), 'dataset'
    @route RegExp('dataset/([^/]+)/view/([^/]+)/?'), 'view'
    @route RegExp('dataset/([^/]+)/plugin/([^/]+)/?'), 'plugin'
    @route RegExp('create-profile/?'), 'createProfile'
    @route RegExp('set-password/([^/]+)/?'), 'setPassword'

  main: ->
    window.datasets.fetch
      success: =>
        titleView = new Cu.View.Title {text: 'My Datasets'}
        contentView = new Cu.View.DatasetList {collection: window.datasets}
        @titleView.showView titleView
        @appView.showView contentView
      error: (x,y,z) ->
        console.warn 'ERRROR', x, y, z

  tools: ->
    window.tools.fetch
      success: =>
        titleView = new Cu.View.Title {text: 'My Tools'}
        contentView = new Cu.View.ToolList {collection: window.tools}
        @titleView.showView titleView
        @appView.showView contentView
      error: (x,y,z) ->
        console.warn 'ERRROR', x, y, z

  tool: (tool) ->
    window.tools.fetch
      success: =>
        model = window.tools.get tool
        titleView = new Cu.View.Title {text: "My Tools / #{model.get('manifest').displayName}" }
        contentView = new Cu.View.ToolContent {model: model}
        @titleView.showView titleView
        @appView.showView contentView
      error: (x,y,z) ->
        console.warn 'ERRROR', x, y, z

  dataset: (box) ->
    mod = Cu.Model.Dataset.findOrCreate box: box
    mod.fetch
      success: (model, resp, options) =>
        window.tools.fetch
          success: =>
            titleView = new Cu.View.DataSetTitle {model: model}
            contentView = new Cu.View.DataSetOverview { model: model, tools: window.tools }
            @titleView.showView titleView
            @appView.showView contentView
          error: (x,y,z) ->
            console.warn 'ERRROR', x, y, z
      error: (model, xhr, options) ->
        console.warn xhr

  plugin: (datasetId, pluginName) ->
    dataset = Cu.Model.Dataset.findOrCreate
      user: window.user.effective.shortName
      box: datasetId

    dataset.fetch
      success: (dataset, resp, options) =>
        # install plugin to dataset
        #
        dataset.installPlugin pluginName, (err, view) ->
          console.warn 'Error', err if err?
          window.app.navigate "/dataset/#{dataset.id}/view/#{view.id}", trigger: true
      error: (model, xhr, options) ->
        console.warn xhr

  view: (datasetID, viewID) ->
    dataset = Cu.Model.Dataset.findOrCreate
      user: window.user.effective.shortName
      box: datasetID

    dataset.fetch
      success: (dataset, resp, options) =>
        window.tools.fetch
          success: =>
            v = dataset.get('views').findById(viewID)
            titleView = new Cu.View.ViewTitle {model: v}
            contentView = new Cu.View.ViewContent {model: v}
            @titleView.showView titleView
            @appView.showView contentView
      error: (model, xhr, options) ->
        console.warn xhr

  createProfile: ->
    titleView = new Cu.View.Title {text: 'Create Profile'}
    contentView = new Cu.View.CreateProfile()
    @titleView.showView titleView
    @appView.showView contentView

  setPassword: ->
    titleView = new Cu.View.Title {text: 'Set your password'}
    contentView = new Cu.View.SetPassword()
    @titleView.showView titleView
    @appView.showView contentView

  fourOhFour: ->
    titleView = new Cu.View.Title {text: '404: Not Found'}
    contentView = new Cu.View.FourOhFour()
    @titleView.showView titleView
    @appView.showView contentView
