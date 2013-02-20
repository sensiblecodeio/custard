class Cu.View.DatasetList extends Backbone.View
  className: 'dataset-list'

  events:
    'click .new-dataset': 'showChooser'

  render: ->
    # :TODO: This is such a hack - we need to find a better way
    @$el.append '<a class="new-dataset tile" title="Add a new dataset">+</a>'
    @addDatasets()

    # Fetch tools here so #chooser appears immediately after click
    window.tools.fetch
      error: ->
        console.log "couldn't fetch tools!!" # Need to handle this later!!
    @

  addDatasets: ->
    @collection.visible().each @addDataset

  addDataset: (dataset) =>
    view = new Cu.View.DatasetTile model: dataset
    @$el.append view.render().el

  showChooser: ->
    # :TODO: This assumes window.tools.fetch worked in @render()
    t = new Cu.View.ToolList {collection: window.tools}
    $('body').append t.render().el