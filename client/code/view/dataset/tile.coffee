class Cu.View.DatasetTile extends Backbone.View
  className: 'dataset tile swcol'
  tagName: 'a'
  attributes: ->
    if @options.details?
      href: "/dataset/#{@model.get 'box'}/settings"
      'data-box': @model.get 'box'
    else
      href: "/dataset/#{@model.get 'box'}"
      'data-box': @model.get 'box'

  events:
    'click .hide': 'hideDataset'
    'click .dropdown-menu a': 'dropdownMenuItemClick'
    'click .rename-dataset': 'renameDatasetClick'
    'click .git-ssh': ->
      Cu.Helpers.showOrAddSSH @model.get('box'), @model.get('displayName'), 'dataset'

  initialize: ->
    @model.on 'change', @render, this
    @model.on 'destroy', @destroy, this

  render: ->
    @$el.html JST['dataset-tile']
      dataset: @model.toJSON()
      statusUpdatedHuman: @model.statusUpdatedHuman()
    @

  destroy: ->
    @remove()

  hideDataset: (e) ->
    e.preventDefault()
    e.stopPropagation()
    @$el.fadeOut()
    @model.save {state: 'deleted'}

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
