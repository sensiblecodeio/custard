window.DatasetListView = class DatasetListView extends Backbone.View
  initialize: ->
    @addDataSets()

  addDataSets: ->
    console.dir @collection
    @collection.each @addDataset

  addDataset: (dataset) ->
    $('#datasets').append """
       <div class="metro-tile #{dataset.get 'name'}">
          <h3>#{dataset.get 'name'} data</h3>
       </div>
    """
