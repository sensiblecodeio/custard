class Cu.View.DatasetOverview extends Backbone.View
  className: 'dataset-overview'

  events:
    'click .new-view': 'showChooser'

  render: ->
    datasetTileView = new Cu.View.DatasetTile
      model: @model
      details: true
    @$el.append datasetTileView.render().el
    viewsView = new Cu.View.DatasetViews model: @model
    @$el.append viewsView.render().el
    @

  showChooser: ->
    # :TODO: We shouldn't be fetching tools in here.
    # :TODO: This is duplicated in view/subnav-path.coffee (for creating Datasets)
    if window.tools.length == 0
      window.tools.fetch
        success: ->
          t = new Cu.View.ToolList {collection: window.tools, type: 'nonimporters', dataset: @model}
          $('body').append t.render().el
        error: (x,y,z) ->
          console.warn 'ERRROR', x, y, z
    else
      t = new Cu.View.ToolList {collection: window.tools, type: 'nonimporters', dataset: @model}
      $('body').append t.render().el