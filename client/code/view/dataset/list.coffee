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
    'click th.sortable': 'sortTable'

  render: ->
    if window.user.effective.datasetDisplay == 'list'
      @renderAsList()
    else
      @renderAsTiles()
    @

  renderAsList: =>
    arrows = '<i class="icon-chevron-up"></i><i class="icon-chevron-down"></i>'
    @$el.removeClass('row').addClass('row-fluid')
    @$el.html """<table class="table table-hover">
      <thead>
        <tr>
          <th class="icon"></th>
          <th class="name sortable">Name #{arrows}</th>
          <th class="status sortable">Status #{arrows}</th>
          <th class="updated sortable">Last run #{arrows}</th>
          <th class="creator sortable">Created by #{arrows}</th>
          <th class="created sortable">Created #{arrows}</th>
          <th class="hide"></th>
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

  sortTable: (e) ->
    $th = $(e.currentTarget)
    columnNumber = $th.prevAll().length
    if $th.is '.sorted-asc'
      sortOrder = 'desc'
      $th.removeClass('sorted-asc').addClass 'sorted-desc'
    else
      sortOrder = 'asc'
      $th.removeClass('sorted-desc').addClass 'sorted-asc'

    $th.siblings().removeClass 'sorted-asc sorted-desc'

    $('tbody>tr', @$el).tsort 'td:eq(' + columnNumber + ')',
      order: sortOrder
      attr: 'data-sortable-value'
