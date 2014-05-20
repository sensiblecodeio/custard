class Cu.View.DatasetRow extends Backbone.View
  tagName: 'tr'
  className: 'dataset'
  attributes: ->
    'data-box': @model.get 'box'

  events:
    'click .hide': 'hideDataset'
    'click .unhide': 'unhideDataset'
    'click': 'visitDataset'

  initialize: (options) ->
    @options = options || {}

    # Check whether a `clickable` option has been passed to
    # this view's constructor (eg: by Cu.View.Dashboard).
    if @options.clickable?
      @clickable = @options.clickable

    @model.on 'change', @render, this
    @model.on 'destroy', @destroy, this

  render: ->
    if @model.get('state') is 'deleted'
      @$el.addClass 'deleted'
      @$el.html JST['dataset-row-deleted']
    else
      toolManifest = @model.get('tool')?.get('manifest')
      @$el.removeClass 'deleted'
      if @model.get('status')?.type is 'error'
        @$el.addClass 'error'
      @$el.html JST['dataset-row']
        dataset: @model.toJSON()
        statusUpdatedHuman: @model.statusUpdatedHuman()
        datasetCreatedHuman: @model.datasetCreatedHuman()
        swatchColor: toolManifest?.color
    @

  destroy: =>
    @remove()

  visitDataset: =>
    if @clickable
      app.navigate "/dataset/#{@model.get 'box'}", trigger: true

  hideDataset: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.destroy()
    @timeout = setTimeout(@destroy, 5 * 60000)

  unhideDataset: (e) ->
    e.preventDefault()
    e.stopPropagation()

    clearTimeout(@timeout)
    @model.recover()

  # Whether or not to make this dataset row clickable.
  # (Cu.View.Dashboard sets this to false, because
  # dataset rows there shouldn't be clickable).
  clickable: true
