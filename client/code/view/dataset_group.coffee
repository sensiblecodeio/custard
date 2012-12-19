class Cu.View.DataSetGroup extends Backbone.View
  className: 'dataset-group'
  events:
    'click': 'click'

  render: ->
    @addDataSet()
    @

  addViews: ->

  click: ->
    window.app.navigate "dataset/#{@model.id}", {trigger: true}
