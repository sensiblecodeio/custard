class Cu.View.ToolTile extends Backbone.View
  className: 'tool'
  tagName: 'a'
  attributes: ->
    href: "/dataset/#{@options.dataset.get 'box'}/plugin/#{@model.get 'name'}"
  initialize: ->
    @model.on 'change', @render, this

  render: ->
    @$el.html JST['tool-tile'] @model.toJSON()
    @
