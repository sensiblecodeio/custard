class Cu.View.ToolList extends Backbone.View
  className: 'my-tools'
    
  render: ->
    @addTools()
    @

  addTools: ->
    @collection.importers().each @addTool

  addTool: (tool) =>
    view = new Cu.View.ToolTile model: tool
    @$el.append view.render().el
