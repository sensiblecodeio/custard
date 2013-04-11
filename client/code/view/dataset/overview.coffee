class Cu.View.DatasetOverview extends Backbone.View
  className: 'dataset-overview row'

  events:
    'click .new-view': 'showChooser'

  render: ->
    $aboutDiv = $('<div class="about swcol">')
    $actionDiv = $('<div class="actions swcol">')

    $aboutDiv.html '<h4>About this data:</h4>'
    datasetTileView = new Cu.View.DatasetTile
      model: @model
      details: true
    $aboutDiv.append datasetTileView.render().el
    datasetActionsView = new Cu.View.DatasetActions
      model: @model
    $aboutDiv.append datasetActionsView.render().el

    $actionDiv.html '<h4>Do something with this data:</h4>'
    viewsView = new Cu.View.DatasetViews model: @model
    $actionDiv.append viewsView.render().el
    if @model.get('views').visible().length > 0
      buttonText = 'Use another tool&hellip;'
    else
      buttonText = 'See more tools&hellip;'
    $actionDiv.append """<span class="btn btn-large new-view"><img src="/image/chooser-icon-24px.png" width="24" height="24">#{buttonText}</span>"""

    @$el.append $aboutDiv, $actionDiv

    # close the tool chooser if it's open
    # (ie: if we've just used the back button to close it)
    if $('#chooser').length
      $('#chooser').fadeOut 200, ->
          $(this).remove()
      $(window).off('keyup')
    @

  showChooser: ->
     t = new Cu.View.ToolList {collection: window.tools, type: 'nonimporters', dataset: @model}
     app.navigate "#{window.location.pathname}#chooser"
     $('body').append t.render().el
