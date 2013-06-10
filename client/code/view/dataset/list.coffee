class Cu.View.DatasetList extends Backbone.View
  className: 'dataset-list row'

  initialize: ->
    app.datasets().on 'add', @addDataset, @
    app.datasets().on 'change:state', @addDatasets, @

  events:
    'click .new-dataset-tile': ->
      $('#subnav .new-dataset').trigger('click') # :TODO: this is nasty and hacky

  render: ->
    @$el.append $('<a class="new-dataset-tile swcol" title="Add a new dataset">Create a<br/>new dataset</a>').hide().fadeIn(150)
    @$el.remove('.dataset')
    @addDatasets() if app.datasets().length
    @

  addDatasets: ->
    @$el.remove('.dataset')
    app.datasets().each @addDataset

  addDataset: (dataset) =>
    alreadyThere = @$el.find("[data-box=#{dataset.get 'box'}]").length

    if not alreadyThere and dataset.get('state') isnt 'deleted'
      view = new Cu.View.DatasetTile model: dataset
      @$el.append view.render().el
