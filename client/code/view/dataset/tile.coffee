class Cu.View.DatasetTile extends Backbone.View
  className: 'dataset tile swcol'
  tagName: 'a'
  attributes: ->
    'data-box': @model.get 'box'

  events:
    'click .hide': 'hideDataset'
    'click .unhide': 'unhideDataset'

  initialize: ->
    @model.on 'change', @render, this
    @model.on 'destroy', @destroy, this

  render: ->
    if @model.get('state') is 'deleted'
      @$el.css 'background-color', ''
      @$el.removeAttr 'href'
      @$el.addClass 'deleted'
      @$el.html JST['dataset-tile-deleted']
    else
      toolManifest = @model.get('tool')?.get('manifest')
      if toolManifest?.color
        @$el.css 'background-color', toolManifest.color
      @$el.attr 'href', "/dataset/#{@model.get 'box'}"
      @$el.removeClass 'deleted'
      @$el.html JST['dataset-tile']
        dataset: @model.toJSON()
        statusUpdatedHuman: @model.statusUpdatedHuman()
    @

  destroy: =>
    @remove()

  hideDataset: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @timeout = setTimeout(@destroy, 5 * 60000)

    fiveMinutesInFuture = new Date(new Date().getTime() + 5 * 60000)
    @model.save {state: 'deleted', toBeDeleted: fiveMinutesInFuture}

  unhideDataset: (e) ->
    e.preventDefault()
    e.stopPropagation()

    clearTimeout(@timeout)

    @model.save {state: null, toBeDeleted: null}
