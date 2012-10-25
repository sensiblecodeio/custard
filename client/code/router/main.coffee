window.MainRouter = class MainRouter extends Backbone.Router
  routes:
    "": "main"
    "tool": "tool"

  header: null
  content: null

  main: ->
    $('body').attr 'class', ''
    @header = new HomeHeaderView()
    @content = new HomeContentView()

  tool: ->
    $('body').attr 'class', 'tool'
    @header = new ToolHeaderView()
    @content = new ToolContentView()

