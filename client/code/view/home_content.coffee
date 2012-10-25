window.HomeContentView = class HomeContentView extends Backbone.View
  events:
    'click .metro-tile': 'click_tile'

  el: '#content'

  initialize: ->
    @render()

  render: ->
    @$el.empty()
    @$el.load 'home_content'
    
  click_tile: ->
    app.navigate 'tool', {trigger: true}

