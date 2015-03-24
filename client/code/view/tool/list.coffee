class Cu.View.ToolList extends Backbone.View
  id: 'chooser'

  events:
    'click .close': 'closeChooser'
    'click': 'closeChooser'

  initialize: (options) ->
    @options = options || {};
    
    app.tools().on 'fetched', @addTools, @

    Backbone.on 'error', =>
      # close chooser on errors,
      # so user can see red alert bar behind
      @closeChooser()

    $(window).on 'keyup', (e) =>
      if e.which == 27
        @closeChooser()

  render: ->
    @$el.hide().append('<span class="close">&times;</span>')
    headerView = new Cu.View.ToolListHeader {type: @options.type}
    @$el.append headerView.render().el
    @container = $('<div class="container">').appendTo @$el
    @addTools() if app.tools().length
    @$el.fadeIn 200
    return this

  addTools: ->
    @$el.remove('.tool')
    categories = _.groupBy app.tools().toArray(), (tool) ->
      tool.get('manifest')?.category || "Other"

    for category, tools of categories
      console.log "category:", category, tools
      @addToolCategory category, tools

  addToolCategory: (category, tools) =>
    $('<h3>' + category + '</h3>').appendTo @container
    row = $('<div class="row">').appendTo @container
    for tool in tools
      @addTool row, tool

  addTool: (row, tool) =>
    if @options.type is 'importers' and tool.get('type') is 'importer'
      view = new Cu.View.AppTile model: tool
      view.on 'install:failed', =>
        @closeChooser false
      , @
      row.append view.render().el
    else if @options.type isnt 'importers' and tool.get('type') isnt 'importer'
      view = new Cu.View.PluginTile { model: tool, dataset: @options.dataset }
      row.append view.render().el

  closeChooser: (navigate=true) ->
    @$el.fadeOut 200, =>
      # TODO: we want to go back to the last page, but
      # on our site only window.history.back() will screw up stuff
      if @options.type is 'importers'
        if navigate then app.navigate '/datasets', trigger: Backbone.history.routeCount < 2
      else
        if navigate then app.navigate "/dataset/#{@options.dataset.get 'box'}", trigger: Backbone.history.routeCount < 2
    $(window).off('keyup')
