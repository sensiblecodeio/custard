class Cu.View.ToolTile extends Backbone.View
  className: 'tool'
  tagName: 'a'
  initialize: ->
    @model.on 'change', @render, this

  render: ->
    @$el.html JST['tool-tile'] @model.toJSON()
    @

class Cu.View.AppTile extends Cu.View.ToolTile
  attributes: ->
    href: "/tool/#{@model.get 'name'}"

class Cu.View.PluginTile extends Cu.View.ToolTile
  attributes: ->
    href: "/dataset/#{@options.dataset.get 'box'}/plugin/#{@model.get 'name'}"
