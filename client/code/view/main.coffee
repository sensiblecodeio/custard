window.HomeHeaderView = class HomeHeaderView extends Backbone.View
  el: '#header'

  initialize: ->
    @render()

  render: ->
    console.log $(@el)
    $(@el).load '/home_header'
    
