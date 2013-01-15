class Cu.View.DatasetList extends Backbone.View
  className: 'dataset-list'

  render: ->
    @addDataSets()
    @

  addDataSets: ->
    @collection.each @addDataset

  addDataset: (dataset) =>
    view = new Cu.View.DataSetGroup model: dataset
    @$el.append view.render().el
