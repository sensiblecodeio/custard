window.datasets = new Cu.Collection.DatasetList
class Cu.Router.Main extends Backbone.Router

  initialize: ->
    @route RegExp('^/?$'), 'main'
    @route RegExp('tool/([^/]+)/?'), 'tool'
    @route RegExp('dataset/([^/]+)/?'), 'dataset'
    @route RegExp('new-profile/?'), 'newProfile'
    @route RegExp('set-password/([^/]+)/?'), 'setPassword'

  main: ->
    model = new Cu.Model.Tool { id: 1, name: 'highrise' }
    $('body').attr 'class', ''
    window.header = new Cu.View.HomeHeader()
    window.content = new Cu.View.HomeContent {model: model}
    window.datasets.fetch
      success: ->
        new Cu.View.DatasetList {collection: window.datasets, el: '#datasets'}


  tool: (tool) ->
    num = String(Math.random()).replace '.',''
    model = new Cu.Model.Tool
      name: 'highrise'
      box_name: 'highrise-' + num.substring(num.length, num.length - 4)
    window.box = model.get 'box_name'
    $('body').attr 'class', 'tool'
    window.header = new Cu.View.ToolHeader {model: model}
    window.content = new Cu.View.ToolContent {model: model}

  dataset: (id) ->
    model = new Cu.Model.Dataset
      user: window.user.shortName
      _id: id
    model.fetch
      success: (model, resp, options) ->
        window.header = new Cu.View.ToolHeader {model: model}
        window.content = new Cu.View.DatasetContent { model: model }
      error: (model, xhr, options) ->
        console.warn xhr


  newProfile: ->
    $('body').attr 'class', 'admin'
    window.header = new Cu.View.AdminHeader('Create a new profile')
    window.content = new Cu.View.AdminContent()

  setPassword: ->
    $('body').attr 'class', 'admin'
    window.header = new Cu.View.AdminHeader('Set your password')
    window.content = new Cu.View.SetPassword()
