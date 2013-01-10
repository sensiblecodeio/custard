class Cu.View.DataSetTools extends Backbone.View
  className: 'dataset-tools'

  render: ->
    @$el.append '<h4>Tools:</h4>'
    @addTools()
    @

  addTools: =>
    @collection.nonimporters().each @addTool

  addTool: (tool) =>
    @$el.append JST['tool'] tool.toJSON()