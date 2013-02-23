class Cu.View.DatasetList extends Backbone.View
  className: 'dataset-list'

  events:
    'click .new-dataset': ->
      $('#subnav .new-dataset').trigger('click') # :TODO: this is nasty and hacky

  render: ->
    @$el.append '<a class="new-dataset tile" title="Add a new dataset">+</a>'
    @addDatasets()
    @

  addDatasets: ->
    @collection.visible().each @addDataset

  addDataset: (dataset) =>
    view = new Cu.View.DatasetTile model: dataset
    @$el.append view.render().el