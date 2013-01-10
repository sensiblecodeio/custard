class Cu.View.ToolTile extends Backbone.View
  className: 'tool'
  tagName: 'a'
  attributes: ->
    href: "/tool/#{@model.attributes.name}"

  initialize: ->
    @model.on 'change', @render, this

  render: ->
    @$el.html JST['tool-tile'] @model.toJSON()
    @
