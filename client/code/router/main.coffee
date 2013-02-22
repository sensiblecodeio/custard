num = String(Math.random()).replace '.',''


window.datasets = new Cu.Collection.DatasetList()
window.tools = new Cu.Collection.Tools()

Backbone.View::close = ->
  @off()
  @remove()

class Cu.Router.Main extends Backbone.Router

  initialize: ->
    @appView = new Cu.AppView '#content'
    @subnavView = new Cu.AppView '#subnav'
    @navView ?= new Cu.View.Nav()

    # Move somewhere better
    $('#logo').click ->
      event.preventDefault()
      window.app.navigate "/", {trigger: true}

    # Backbone seems to reverse route order
    # TODO: revert to standard routes?
    @route RegExp('.*'), 'fourOhFour'
    @route RegExp('^/?$'), 'main'
    @route RegExp('docs/?'), 'docs'
    @route RegExp('tools/?'), 'tools'
    @route RegExp('dataset/([^/]+)/?'), 'dataset'
    @route RegExp('dataset/([^/]+)/settings/?'), 'datasetSettings'
    @route RegExp('dataset/([^/]+)/view/([^/]+)/?'), 'view'
    @route RegExp('create-profile/?'), 'createProfile'
    @route RegExp('set-password/([^/]+)/?'), 'setPassword'

  main: ->
    window.datasets.fetch
      success: =>
        contentView = new Cu.View.DatasetList {collection: window.datasets}
        subnavView = new Cu.View.DataHubNav
        @appView.showView contentView
        @subnavView.showView subnavView
        window.tools.fetch()
      error: (x,y,z) ->
        console.warn 'ERRROR', x, y, z

  dataset: (box) ->
    mod = Cu.Model.Dataset.findOrCreate box: box
    mod.fetch
      success: (model, resp, options) =>
        contentView = new Cu.View.DatasetOverview {model: model}
        subnavView = new Cu.View.DatasetNav {model: model}
        @appView.showView contentView
        @subnavView.showView subnavView
        window.tools.fetch()
      error: (model, xhr, options) ->
        console.warn xhr

  datasetSettings: (box) ->
    mod = Cu.Model.Dataset.findOrCreate box: box
    mod.fetch
      success: (model) =>
        subnavView = new Cu.View.DatasetSettingsNav {model: model}
        contentView = new Cu.View.AppContent {model: model}
        @appView.showView contentView
        @subnavView.showView subnavView
      error: (x,y,z) ->
        console.warn 'ERRROR', x, y, z

  view: (datasetID, viewID) ->
    dataset = Cu.Model.Dataset.findOrCreate
      user: window.user.effective.shortName
      box: datasetID

    dataset.fetch
      success: (dataset, resp, options) =>
        # :TODO: Why do we fetch tools here?? ~Z
        window.tools.fetch
          success: =>
            v = dataset.get('views').findById(viewID)
            contentView = new Cu.View.PluginContent {model: v}
            subnavView = new Cu.View.ViewNav {model: v}
            @appView.showView contentView
            @subnavView.showView subnavView
      error: (model, xhr, options) ->
        console.warn xhr

  createProfile: ->
    titleView = new Cu.View.Subnav {text: 'Create Profile'}
    contentView = new Cu.View.CreateProfile()
    @appView.showView contentView
    @subnavView.showView subnavView

  setPassword: ->
    subnavView = new Cu.View.Subnav {text: 'Set your password'}
    contentView = new Cu.View.SetPassword()
    @appView.showView contentView
    @subnavView.showView subnavView

  fourOhFour: ->
    subnavView = new Cu.View.Subnav {text: '404: Not Found'}
    contentView = new Cu.View.FourOhFour()
    @appView.showView contentView
    @subnavView.showView subnavView

  docs: ->
    subnavView = new Cu.View.Subnav {text: 'Developer Documentation'}
    contentView = new Cu.View.Docs()
    @appView.showView contentView
    @subnavView.showView subnavView
