window.MainRouter = class MainRouter extends Backbone.Router
  routes:
    "": "main"
    "tool/:tool": "tool"

  header: null
  content: null

  main: ->
    $.get 'apikey', (data) ->
      window.apikey = data
      model = new ToolModel { id: 1, name: 'hello-world' }
      $('body').attr 'class', ''
      @header = new HomeHeaderView()
      @content = new HomeContentView {model: model}

  tool: (tool) ->
    model = new ToolModel { id: 1, name: 'hello-world' }
    $('body').attr 'class', 'tool'
    @header = new ToolHeaderView()
    @content = new ToolContentView {model: model}

