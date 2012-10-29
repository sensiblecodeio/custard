window.MainRouter = class MainRouter extends Backbone.Router
  routes:
    "": "main"
    "tool": "tool"

  header: null
  content: null

  main: ->
    model = new Backbone.Model { id: 1, name: 'Hello world' }
    $('body').attr 'class', ''
    @header = new HomeHeaderView()
    @content = new HomeContentView {model: model}

  tool: ->
    $('body').attr 'class', 'tool'
    @header = new ToolHeaderView()
    @content = new ToolContentView()

