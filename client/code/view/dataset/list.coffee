# The logged-in homepage, showing a user's datasets

class Cu.View.DatasetList extends Backbone.View
  className: 'dataset-list row'

  initialize: ->
    app.datasets().on 'change:state change:displayName', () ->
      app.datasets().sort()
    app.datasets().on 'sort', @addDatasets, @

  events:
    'click .new-dataset-tile': ->
      $('#subnav .new-dataset').trigger('click') # :TODO: this is nasty and hacky

  render: ->
    console.log 'render'
    if window.user.effective.datasetDisplay == 'list'
      @renderAsList()
    else
      @renderAsTiles()
    @

  renderAsList: =>
    @$el.removeClass('row').addClass('row-fluid')
    @$el.html """<table class="table table-hover">
      <thead>
        <tr>
          <th class="icon"></th>
          <th class="name">Name</th>
          <th class="status">Status</th>
          <th class="updated">Last run</th>
          <th class="creator">Created by</th>
          <th class="created">Created</th>
        </tr>
      </thead>
      <tbody>
      </tbody>
    </table>"""
    @addDatasets()
    @

  renderAsTiles: =>
    @$el.removeClass('row-fluid').addClass('row')
    @$el.html '<a class="new-dataset-tile swcol" title="Add a new dataset">Create a<br/>new dataset</a>'
    if app.datasets().length
      app.datasets().sort()
      @addDatasets()
    @

  addDatasets: ->
    @$el.remove('.dataset')
    app.datasets().each @addDataset

  addDataset: (dataset) =>
    alreadyThere = @$el.find("[data-box=#{dataset.get 'box'}]").length

    if not alreadyThere and dataset.get('state') isnt 'deleted'
      if window.user.effective.datasetDisplay == 'list'
        view = new Cu.View.DatasetRow model: dataset
        @$el.find('tbody').append view.render().el
      else
        view = new Cu.View.DatasetTile model: dataset
        @$el.append view.render().el
