window.ToolHeaderView = class ToolHeaderView extends Backbone.View
  el: '#header'

  initialize: ->
    @render()

  render: ->
    @$el.empty()
    @$el.load '/tool_header', =>
      @$el.find('h2 a').text @model.get 'name'
