class Cu.View.DatasetList extends Backbone.View
  events:
    'click .metro-tile': 'clickDataset'

  initialize: ->
    @addDataSets()

  addDataSets: ->
    @collection.each @addDataset

  addDataset: (dataset) ->
    $('#datasets').append """
       <div class="metro-tile #{dataset.get 'name'}">
          <h3>#{dataset.get 'name'} data</h3>
       </div>
    """

  clickDataset: (event) ->
    # TODO: refactor into Dataset view
    name = ($(event.target).first().attr 'class').split(' ')[1]
    window.app.navigate "dataset/#{name}", {trigger: true}
