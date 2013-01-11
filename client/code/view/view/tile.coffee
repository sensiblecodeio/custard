class Cu.View.ViewTile extends Backbone.View
  className: 'view'
  tagName: 'a'
  attributes: ->
    href: "/dataset/#{@model.get('plugsInTo').get('box')}/view/#{@model.get 'box'}"

  initialize: ->
    @model.on 'change', @render, this

  render: ->
    @$el.html JST['view-tile'] @model.toJSON()
    @
