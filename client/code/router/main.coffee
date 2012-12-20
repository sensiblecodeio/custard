num = String(Math.random()).replace '.',''


window.datasets = new Cu.Collection.DatasetList()
window.tools = new Cu.Collection.Tools()

tools.push new Cu.Model.Tool
  name: 'highrise'
  displayName: 'Highrise'
  box_name: 'highrise-' + num.substring(num.length, num.length - 4)
  importer: true

tools.push new Cu.Model.Tool
  name: 'newdataset'
  displayName: 'New Dataset'
  box_name: 'newdataset-' + num.substring(num.length, num.length - 4)
  importer: true

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
    
    @route RegExp('^/?$'), 'main'
    @route RegExp('tool/([^/]+)/?'), 'tool'
    @route RegExp('dataset/([^/]+)/?'), 'dataset'
    @route RegExp('dataset/([^/]+)/([^/]+)/?'), 'view'
    @route RegExp('new-profile/?'), 'newProfile'
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

  tool: (tool) ->
    model = window.tools.get tool
    window.box = model.get 'box_name'
    view = new Cu.View.ToolContent {model: model}
    @appView.showView view

  dataset: (id) ->
    mod = null
    mod = new Cu.Model.Dataset
      user: window.user.effective.shortName
      _id: id
    mod.fetch
      success: (model, resp, options) =>
        # Title?
        titleView = new Cu.View.DataSetTitle {model: model}
        contentView = new Cu.View.DataSetOverview { model: model }
        @titleView.showView titleView
        @appView.showView contentView
      error: (model, xhr, options) ->
        console.warn xhr

  view: (datasetID, viewName) ->
    mod = null
    mod = new Cu.Model.Dataset
      user: window.user.effective.shortName
      _id: datasetID
    mod.fetch
      success: (model, resp, options) =>
        # Title?
        view = new Cu.View.ViewContent { model: model, viewName: viewName }
        @appView.showView view
      error: (model, xhr, options) ->
        console.warn xhr

  newProfile: ->
    $('body').attr 'class', 'admin'
    window.header = new Cu.View.AdminHeader title: 'Create a new profile'
    window.content = new Cu.View.AdminContent()

  setPassword: ->
    window.header = new Cu.View.HomeHeader()
    window.content = new Cu.View.SetPassword()
