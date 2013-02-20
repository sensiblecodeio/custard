class Cu.View.ToolList extends Backbone.View
  id: 'chooser'

  events:
    'click .close': 'closeChooser'
    'click': 'closeChooser'

  render: ->
    # :TODO: should this go in a template?
    @container = $('<div class="container">')
    @container.append('<h2>Create a new dataset</h2>')
    @container.append('<a class="close">&times;</a>')
    @addTools()
    @$el.hide().append(@container).fadeIn(100)

    # :TODO: this is probably the wrong place to be binding an event
    $(window).on 'keyup', (e) =>
      if e.which == 27
        @closeChooser()
    @

  addTools: ->
    @collection.importers().each @addTool

  addTool: (tool) =>
    view = new Cu.View.AppTile model: tool
    @container.append view.render().el

  closeChooser: ->
    @$el.fadeOut 200, ->
        $(this).remove()
    $(window).off('keyup')
