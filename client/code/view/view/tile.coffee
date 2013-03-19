class Cu.View.ViewTile extends Backbone.View
  className: 'view tile'
  tagName: 'a'
  attributes: ->
    href: "/dataset/#{@model.get('plugsInTo').get('box')}/view/#{@model.get 'box'}"

  events:
    'click .hide-view': 'hideView'
    'click .dropdown-menu a': 'dropdownMenuItemClick'
    'click .rename-view': 'renameViewClick'
    'click .git-ssh': ->
      Cu.Helpers.showOrAddSSH @model.get('box')

  initialize: ->
    @model.on 'change', @render, this

  render: ->
    @$el.html JST['view-tile'] @model.toJSON()

    # :TODO: Make this suck less
    if /spreadsheet/i.test @model.get('name')
      @$el.addClass 'spreadsheet'
    if /download/i.test @model.get('name')
      @$el.addClass 'download'
    if /newdataset/i.test @model.get('name')
      @$el.addClass 'source'
    @

  dropdownMenuItemClick: (e) ->
    e.preventDefault()
    e.stopPropagation()

  hideView: (e) ->
    @$el.slideUp()
    @model.set 'state', 'deleted'
    @model.get('plugsInTo').save {},
      error: (e) =>
        @$el.slideDown()
        console.warn 'View could not be deleted!'

  renameViewClick: ->
    # This is a bit of a hack, to avoid writing yet another rename widget.
    # Hopefully it'll also teach people they can directly edit dataset names.
    window.app.navigate "/dataset/#{@model.get('plugsInTo').get('box')}/view/#{@model.get('box')}", trigger: true
    setTimeout ->
      $('#subnav-path .editable').trigger('click')
    , 300


