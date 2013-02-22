class Cu.View.DatasetOverview extends Backbone.View
  className: 'dataset-overview'

  events:
    'click .new-view': 'showChooser'

  render: ->
    $aboutDiv = $('<div class="about">')
    $actionDiv = $('<div class="actions">')

    $aboutDiv.html '<h4>About this data:</h4>'
    datasetTileView = new Cu.View.DatasetTile
      model: @model
      details: true
    $aboutDiv.append datasetTileView.render().el

    $actionDiv.html '<h4>Analyse and export this data:</h4>'
    viewsView = new Cu.View.DatasetViews model: @model
    $actionDiv.append viewsView.render().el
    if @model.get('views').visible().length > 0
      buttonText = 'Use another tool&hellip;'
    else
      buttonText = 'See more tools&hellip;'
    $actionDiv.append """<span class="btn btn-large new-view"><img src="/image/chooser-icon-24px.png" width="24" height="24">#{buttonText}</span>"""

    @$el.append $aboutDiv, $actionDiv
    @

  showChooser: ->
    # :TODO: We shouldn't be fetching tools in here.
    # :TODO: This is duplicated in view/subnav.coffee (for creating Datasets)
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