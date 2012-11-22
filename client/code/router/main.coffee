window.MainRouter = class MainRouter extends Backbone.Router

  initialize: ->
    @route RegExp('^/?$'), 'main'
    @route RegExp('tool/([^/]+)/?'), 'tool'
    @route RegExp('new-profile/?'), 'newProfile'
    @route RegExp('set-password/([^/]+)/?'), 'setPassword'

  header: null
  content: null

  main: ->
    @_setApiKey =>
      model = new ToolModel { id: 1, name: 'highrise' }
      $('body').attr 'class', ''
      @header = new HomeHeaderView()
      @content = new HomeContentView {model: model}

  tool: (tool) ->
    @_setApiKey =>
      num = String(Math.random()).replace '.',''
      model = new ToolModel
        name: 'highrise'
        box_name: 'highrise-' + num.substring(num.length, num.length - 4)
      window.user = 'cotest'
      window.box = model.get 'box_name'
      $('body').attr 'class', 'tool'
      @header = new ToolHeaderView {model: model}
      @content = new ToolContentView {model: model}

  newProfile: ->
    $('body').attr 'class', 'admin'
    @header = new AdminHeaderView('Create a new profile')
    @content = new AdminContentView()

  setPassword: ->
    $('body').attr 'class', 'admin'
    @header = new AdminHeaderView('Set your password')
    @content = new SetPasswordView()

  _setApiKey: (callback) ->
    $.get '/tpl/apikey', (data) ->
      window.apikey = data
      callback()
