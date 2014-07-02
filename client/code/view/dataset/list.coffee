# The logged-in homepage, showing a user's datasets

guiderNewDataset = (attachTo) ->
  guiders.createGuider(
    attachTo: attachTo
    buttons: [ ]
    description: "A dataset is an updating table of information from one source, e.g. a Twitter search query, or a PDF."
    id: "guider-new-dataset"
    position: 6
    title: "Hi! First, make a new dataset"
    width: 300
    xButton: false
  ).show()

class Cu.View.DatasetList extends Backbone.View
  className: 'dataset-list row'

  initialize: ->
    app.datasets().on 'change:state change:displayName', () ->
      app.datasets().sort()
    app.datasets().on 'sort', @addDatasets, @

    # Load saved column sorting
    app.datasets().on 'sync', () =>
      if Backbone.history.getFragment() != 'datasets'
        return
      if $.cookie("dataset-sort-class")
        colSelector = "." + $.cookie("dataset-sort-class") + ".sortable"
        @sortTable $(colSelector), $.cookie("dataset-sort-order")

    # Guiders
    app.datasets().on 'sync', () ->
      if Backbone.history.getFragment() != 'datasets'
        return
      if not app.datasets().length
        setTimeout ->
          # This is the optimizely id for the "Create dataset guider" experiment.
          # We only show the guider when the user is in the Variant #1 bucket for it.
          if window['optimizely'].data.state.variationMap[1346607875] == 1
            if window.user.effective.datasetDisplay == 'list'
              guiderNewDataset('.new-dataset')
            else
              guiderNewDataset('.new-dataset-tile')
        , 1
    app.on 'route', () ->
      guiders.hideAll()

  events:
    'click .new-dataset-tile': ->
      $('#subnav .new-dataset').trigger('click') # :TODO: this is nasty and hacky
    'click th.sortable': 'sortTableToggle'

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

  sortTableToggle: (e) ->
    $th = $(e.currentTarget)
    if $th.is '.sorted-asc'
      sortOrder = 'desc'
    else
      sortOrder = 'asc'
    @sortTable $th, sortOrder

  sortTable: ($th, sortOrder) ->
    if sortOrder == 'desc'
      $th.removeClass('sorted-asc').addClass 'sorted-desc'
    else
      $th.removeClass('sorted-desc').addClass 'sorted-asc'
    $th.siblings().removeClass 'sorted-asc sorted-desc'

    # Save column sorting
    $.cookie("dataset-sort-class", $th.attr('class').split(' ')[0])
    $.cookie("dataset-sort-order", sortOrder)

    columnNumber = $th.prevAll().length
    $('tbody>tr', @$el).tsort 'td:eq(' + columnNumber + ')',
      order: sortOrder
      attr: 'data-sortable-value'
