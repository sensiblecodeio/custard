class Cu.View.DataSetViews extends Backbone.View
  className: 'dataset-views'

  render: ->
    @$el.append JST['dataset-views'] dataset: @model.toJSON()
    @
