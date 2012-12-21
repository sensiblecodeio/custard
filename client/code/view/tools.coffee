class Cu.View.ToolList extends Backbone.View
  className: 'my-tools'
    
  render: ->
    @addTools()
    @

  addTools: ->
    @collection.importers().each @addTool

  addTool: (tool) =>
    @$el.append JST['tool'](tool.toJSON())
