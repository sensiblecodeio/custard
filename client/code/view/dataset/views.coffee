class Cu.View.DataSetViews extends Backbone.View
  className: 'dataset-views'

  render: ->
    # Cheating
    @$el.append JST['dataset-views'] dataset: @model.toJSON()
    @
