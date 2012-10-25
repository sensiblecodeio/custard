window.ToolHeaderView = class ToolHeaderView extends Backbone.View
  el: '#header'

  initialize: ->
    @render()

  render: ->
    @$el.empty()
    @$el.load 'tool_header'
    
