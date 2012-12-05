class Cu.View.DatasetList extends Backbone.View
  events:
    'click #datasets .metro-tile': 'clickDataset'

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

  clickDataset: (event_) ->
    window.app.navigate "dataset/#{@model.get 'name'}", {trigger: true}
