window.datasets = new DatasetListCollection
window.MainRouter = class MainRouter extends Backbone.Router

  initialize: ->
    @route RegExp('^/?$'), 'main'
    @route RegExp('tool/([^/]+)/?'), 'tool'
    @route RegExp('new-profile/?'), 'newProfile'
    @route RegExp('set-password/([^/]+)/?'), 'setPassword'

  main: ->
    model = new ToolModel { id: 1, name: 'highrise' }
    $('body').attr 'class', ''
    window.header = new HomeHeaderView()
    window.content = new HomeContentView {model: model}
    window.datasets.fetch
      success: ->
        new DatasetListView {collection: window.datasets, el: '#datasets'}


  tool: (tool) ->
    num = String(Math.random()).replace '.',''
    model = new ToolModel
      name: 'highrise'
      box_name: 'highrise-' + num.substring(num.length, num.length - 4)
    window.box = model.get 'box_name'
    $('body').attr 'class', 'tool'
    window.header = new ToolHeaderView {model: model}
    window.content = new ToolContentView {model: model}

  newProfile: ->
    $('body').attr 'class', 'admin'
    window.header = new AdminHeaderView('Create a new profile')
    window.content = new AdminContentView()

  setPassword: ->
    $('body').attr 'class', 'admin'
    window.header = new AdminHeaderView('Set your password')
    window.content = new SetPasswordView()
