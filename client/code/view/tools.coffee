class Cu.View.ToolList extends Backbone.View
  id: 'chooser'

  events:
    'click .close': 'closeChooser'
    'click': 'closeChooser'

  render: ->
    # :TODO: should this go in a template?
    @container = $('<div class="container">')
    if @options.type == 'importers'
      @container.append('<h2>Create a new dataset&hellip;</h2>')
    else
      @container.append('<h2>What would you like to do?</h2>')
    @container.append('<span class="close">&times;</span>')
    @addTools()
    @$el.hide().append(@container).fadeIn(100)

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
