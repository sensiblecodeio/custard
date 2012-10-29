window.MainRouter = class MainRouter extends Backbone.Router
  routes:
    "": "main"
    "tool/:tool": "tool"

  header: null
  content: null

  main: ->
    model = new Backbone.Model { id: 1, name: 'hello-world' }
    $('body').attr 'class', ''
    @header = new HomeHeaderView()
    @content = new HomeContentView {model: model}

  tool: (tool) ->
    model = new Backbone.Model { id: 1, name: 'hello-world' }
    $('body').attr 'class', 'tool'
    @header = new ToolHeaderView()
    @content = new ToolContentView {model: model}

