class Cu.View.DataSetViews extends Backbone.View
  className: 'dataset-views'
  events:
    'click .spreadsheet': 'clickSpreadsheet'
    'click .csv': 'clickCSV'

  render: ->
    # Cheating
    @$el.append JST['dataset-views']()
    @

  clickSpreadsheet: ->
    window.app.navigate "/dataset/#{@model.id}/spreadsheet", {trigger: true}

  clickCSV: ->
    window.app.navigate "/dataset/#{@model.id}/csv", {trigger: true}
