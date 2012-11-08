window.HomeHeaderView = class HomeHeaderView extends Backbone.View
  el: '#header'

  initialize: ->
    @render()

  render: ->
    @$el.empty()
    @$el.load '/tpl/home_header', =>
      topAndTailDropdowns()
    
