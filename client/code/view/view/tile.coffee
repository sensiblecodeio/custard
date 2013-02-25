class Cu.View.ViewTile extends Backbone.View
  className: 'view tile'
  tagName: 'a'
  attributes: ->
    href: "/dataset/#{@model.get('plugsInTo').get('box')}/view/#{@model.get 'box'}"

  events:
    'click .hide': 'hideView'

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

  hideView: (e) ->
    e.preventDefault()
    e.stopPropagation()
    @$el.slideUp()
    @model.set 'state', 'deleted'
    @model.get('plugsInTo').save {},
      error: (e) =>
        @$el.slideDown()
        console.warn 'View could not be deleted!'
