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
    num = String(Math.random()).replace '.',''
    model = new ToolModel
      name: 'hello-world'
      box_name: 'hello-world-' + num.substring(num.length, num.length - 4)
      git_url: 'git://github.com/scraperwiki/hello-world-tool.git'

    $('body').attr 'class', 'tool'
    @header = new ToolHeaderView {model: model}
    @content = new ToolContentView {model: model}

