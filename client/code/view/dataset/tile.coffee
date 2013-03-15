class Cu.View.DatasetTile extends Backbone.View
  className: 'dataset tile swcol'
  tagName: 'a'
  attributes: ->
    if @options.details?
      href: "/dataset/#{@model.attributes.box}/settings"
    else
      href: "/dataset/#{@model.attributes.box}"
  
  events:
    'click .hide': 'hideDataset'
    'click .dropdown-menu a': 'dropdownMenuItemClick'
    'click .rename-dataset': 'renameDatasetClick'
    'click .git-ssh': 'showSSH'

  initialize: ->
    @model.on 'change', @render, this

  render: ->
    @$el.html JST['dataset-tile']
      dataset: @model.toJSON()
      statusUpdatedHuman: @model.statusUpdatedHuman()
    @

  hideDataset: (e) ->
    e.preventDefault()
    e.stopPropagation()
    @$el.fadeOut()
    @model.save {state: 'deleted'},
      error: (e) =>
        @$el.show()
        console.warn 'Dataset could not be deleted!'

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

  showSSH: ->
    alert("This hasn't been implemented yet. Sorry.")
    @closeDropdownMenu()

  closeDropdownMenu: ->
    @$el.find('.actions').removeClass('open')
