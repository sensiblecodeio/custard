class Cu.View.DatasetList extends Backbone.View
  events:
    'click .metro-tile': 'clickDataset'

  initialize: ->
    @addDataSets()

  addDataSets: ->
    @collection.each @addDataset

  addDataset: (dataset) =>
    @$el.append JST['dataset'](dataset.toJSON())

  clickDataset: (event) ->
    # TODO: refactor into Dataset view
    id = ($(event.target).closest('.metro-tile').attr 'class').split(' ')[1]
    window.app.navigate "dataset/#{id}", {trigger: true}
