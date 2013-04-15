class Cu.View.ToolList extends Backbone.View
  id: 'chooser'

  events:
    'click .close': 'closeChooser'
    'click': 'closeChooser'

  initialize: ->
    app.tools().on 'fetched', @addTools, @

    $(window).on 'keyup', (e) =>
      if e.which == 27
        @closeChooser()

  render: ->
    @$el.hide().append('<span class="close">&times;</span>')

    headerView = new Cu.View.ToolListHeader {type: @options.type}
    @$el.append headerView.render().el

    # :TODO: Euch, DOM generation in jQuery. Unclean.
    @container = $('<div class="container">')
    @row = $('<div class="row">').appendTo(@container)
    @addTools() if app.tools().length
    @$el.append(@container).fadeIn(100)

    return this

  addTools: ->
    @$el.remove('.tool')
    app.tools().each @addTool

  addTool: (tool) =>
    if @options.type is 'importers' and tool.get('type') is 'importer'
      view = new Cu.View.AppTile model: tool
      @row.append view.render().el
    else if @options.type isnt 'importers' and tool.get('type') isnt 'importer'
      view = new Cu.View.PluginTile { model: tool, dataset: @options.dataset }
      @row.append view.render().el

  closeChooser: ->
    @$el.fadeOut 200, ->
        $(this).remove()
    $(window).off('keyup')
