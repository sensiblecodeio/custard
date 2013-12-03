class Cu.View.DatasetRow extends Backbone.View
  tagName: 'tr'
  attributes: ->
    'data-box': @model.get 'box'

  events:
    'click .hide': 'hideDataset'
    'click .unhide': 'unhideDataset'
    'click': 'visitDataset'

  initialize: ->
    @model.on 'change', @render, this
    @model.on 'destroy', @destroy, this

  render: ->
    if @model.get('state') is 'deleted'
      @$el.addClass 'deleted'
      @$el.html JST['dataset-tile-deleted']
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
