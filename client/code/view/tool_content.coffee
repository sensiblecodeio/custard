window.ToolContentView = class HomeContentView extends Backbone.View
  el: '#content'

  initialize: ->
    @render()

  render: ->
    @$el.empty()
    @$el.load '/tool_content'
