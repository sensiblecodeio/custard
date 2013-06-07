class Cu.View.DatasetTile extends Backbone.View
  className: 'dataset tile swcol'
  tagName: 'a'
  attributes: ->
    'data-box': @model.get 'box'

  events:
    'click .hide': 'hideDataset'
    'click .unhide': 'unhideDataset'
    'click .dropdown-menu a': 'dropdownMenuItemClick'
    'click .rename-dataset': 'renameDatasetClick'
    'click .git-ssh': ->
      showOrAddSSH  @model, 'dataset'

  initialize: ->
    @model.on 'change', @render, this
    @model.on 'destroy', @destroy, this

  render: ->
    if @model.get('state') is 'deleted'
      @$el.attr 'href', false
      @$el.addClass('deleted').html JST['dataset-tile-deleted']
    else
      @$el.attr 'href', "/dataset/#{@model.get 'box'}"
      @$el.html JST['dataset-tile']
        dataset: @model.toJSON()
        statusUpdatedHuman: @model.statusUpdatedHuman()
    @

  destroy: ->
    @remove()

  hideDataset: (e) ->
    e.preventDefault()
    e.stopPropagation()
    @model.save {state: 'deleted'}

  unhideDataset: (e) ->
    e.preventDefault()
    e.stopPropagation()
    console.log @model.get 'state'
    @model.set 'state', undefined
    console.log @model.get 'state'
    @model.save (err, dataset) ->
      console.log err, dataset

  dropdownMenuItemClick: (e) ->
    e.preventDefault()
    e.stopPropagation()

  renameDatasetClick: ->
    # This is a bit of a hack, to avoid writing yet another rename widget.
    # Hopefully it'll also teach people they can directly edit dataset names.
    window.app.navigate "/dataset/#{@model.attributes.box}", trigger: true
    setTimeout ->
      $('#subnav-path .editable').trigger('click')
    , 300
