class Cu.View.DatasetList extends Backbone.View
  className: 'dataset-list'

  render: ->
    @addDatasets()
    @

  addDatasets: ->
    @collection.visible().each @addDataset

  addDataset: (dataset) =>
    view = new Cu.View.DatasetGroup model: dataset
    @$el.append view.render().el
