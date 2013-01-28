class Cu.View.DataSetDetails extends Backbone.View
  className: 'dataset-details'

  render: ->
    @$el.append JST['dataset-details']()
    datasetView = new Cu.View.DatasetTile
      model: @model
      details: true
    @$el.find('.dataset-description').before datasetView.render().el #ick
    @

