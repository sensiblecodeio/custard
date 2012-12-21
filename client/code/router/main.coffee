num = String(Math.random()).replace '.',''


window.datasets = new Cu.Collection.DatasetList()
window.tools = new Cu.Collection.Tools()

tools.push new Cu.Model.Tool
  name: 'highrise'
  displayName: 'Highrise'
  box_name: 'highrise-' + num.substring(num.length, num.length - 4)
  type: 'importer'

tools.push new Cu.Model.Tool
  name: 'newdataset'
  displayName: 'New Dataset'
  box_name: 'newdataset-' + num.substring(num.length, num.length - 4)
  type: 'importer'

tools.push new Cu.Model.Tool
  name: 'spreadsheet'
  displayName: 'Spreadsheet'
  box_name: 'spreadsheet-' + num.substring(num.length, num.length - 4)
  type: 'view'

tools.push new Cu.Model.Tool
  name: 'csvdownload'
  displayName: 'CSV Download'
  box_name: 'csvdownload-' + num.substring(num.length, num.length - 4)
  type: 'view'

tools.push new Cu.Model.Tool
  name: 'viewsource'
  displayName: 'View Source'
  box_name: 'viewsource-' + num.substring(num.length, num.length - 4)
  type: 'view'

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
    @route RegExp('dataset/([^/]+)/([^/]+)/?'), 'view'
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
    titleView = new Cu.View.Title {text: 'My Tools'}
    contentView = new Cu.View.ToolList {collection: window.tools}
    @titleView.showView titleView
    @appView.showView contentView

  tool: (tool) ->
    model = window.tools.get tool
    window.box = model.get 'box_name'
    titleView = new Cu.View.Title {text: "My Tools / #{model.get 'displayName'}" }
    contentView = new Cu.View.ToolContent {model: model}
    @titleView.showView titleView
    @appView.showView contentView

  dataset: (id) ->
    mod = null
    mod = new Cu.Model.Dataset
      user: window.user.effective.shortName
      _id: id
    mod.fetch
      success: (model, resp, options) =>
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
