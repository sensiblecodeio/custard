class Cu.View.DataSetGroup extends Backbone.View
  className: 'dataset-group'

  render: ->
    @addDataSet()
    @addViews()
    @

  addDataSet: ->
    view = new Cu.View.DatasetTile model: @model
    @$el.html view.render().el

  addViews: =>
    @model.get('views').each @addView

  addView: (view) =>
    v = new Cu.View.ViewTile model: view
    @$el.append v.render().el

  xaddViews: ->
    # Fake for now
    @$el.append """
      <a href="/dataset/#{@model.id}/spreadsheet" class="view spreadsheet">View Spreadsheet</a>
      <a href="/dataset/#{@model.id}/csvdownload" class="view csvdownload">Download CSV</a>
    """
