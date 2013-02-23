class Cu.View.ToolList extends Backbone.View
  id: 'chooser'

  events:
    'click .close': 'closeChooser'
    'click': 'closeChooser'

  render: ->
    @$el.hide().append('<span class="close">&times;</span>')

    headerView = new Cu.View.ToolListHeader {type: @options.type}
    @$el.append headerView.render().el

    @container = $('<div class="container">')
    @addTools()
    @$el.append(@container).fadeIn(100)

    # :TODO: this is probably the wrong place to be binding an event
    $(window).on 'keyup', (e) =>
      if e.which == 27
        @closeChooser()
    @

  addTools: ->
    if @options.type == 'importers'
      @collection.importers().each @addTool
    else
      @collection.nonimporters().each @addTool

  addTool: (tool) =>
    if @options.type == 'importers'
      view = new Cu.View.AppTile model: tool
    else
      view = new Cu.View.PluginTile { model: tool, dataset: @options.dataset }
    @container.append view.render().el

  closeChooser: ->
    @$el.fadeOut 200, ->
        $(this).remove()
    $(window).off('keyup')
