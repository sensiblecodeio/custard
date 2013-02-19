class Cu.View.DatasetList extends Backbone.View
  className: 'dataset-list'

  events:
    'click .new-dataset': 'showChooser'

  render: ->
    # :TODO: This is such a hack - we need to find a better way
    @$el.append '<a class="new-dataset tile" title="Add a new dataset">+</a>'
    @addDatasets()
    @

  addDatasets: ->
    @collection.visible().each @addDataset

  addDataset: (dataset) =>
    view = new Cu.View.DatasetTile model: dataset
    @$el.append view.render().el

  showChooser: ->
    console.log 'showChooser()'