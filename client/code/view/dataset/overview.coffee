class Cu.View.DatasetOverview extends Backbone.View
  className: 'dataset-overview row'

  events:
    'click .new-view': 'showChooser'

  render: ->
    $aboutDiv = $('<div class="about swcol">')

    $aboutDiv.html '<h4>About this data:</h4>'
    datasetTileView = new Cu.View.DatasetTile
      model: @model
      details: true
    $aboutDiv.append datasetTileView.render().el
    datasetActionsView = new Cu.View.DatasetActions
      model: @model
    $aboutDiv.append datasetActionsView.render().el

    @$el.append $aboutDiv

    # close the tool chooser if it's open
    # (ie: if we've just used the back button to close it)
    if $('#chooser').length
      $('#chooser').fadeOut 200, ->
          $(this).remove()
      $(window).off('keyup')
    @

  showChooser: ->
     t = new Cu.View.ToolList {type: 'nonimporters', dataset: @model}
     app.navigate "#{window.location.pathname}#chooser"
     $('body').append t.render().el
