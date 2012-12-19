class Cu.View.DataSetGroup extends Backbone.View
  className: 'dataset-group'
  events:
    'click .dataset': 'clickDataset'
    'click .view': 'clickView'

  render: ->
    @addDataSet()
    @addViews()
    @

  addDataSet: ->
    view = new Cu.View.DataSet model: @model
    @$el.html view.render().el

  addViews: ->
    # Fake for now
    @$el.append """
      <a class="view spreadsheet">View Spreadsheet</a>
      <a class="view download">Download CSV</a>
    """

  clickDataset: ->
    window.app.navigate "/dataset/#{@model.id}", {trigger: true}

  clickView: ->
    # Ew.
    name = ($(event.target).closest('.view').attr 'class').split(' ')[1]
    window.app.navigate "/dataset/#{@model.id}/#{name}", {trigger: true}
