window.HomeContentView = class HomeContentView extends Backbone.View
  events:
    'click .metro-tile': 'clickTile'

  el: '#content'

  initialize: ->
    @render()

  render: ->
    @$el.empty()
    @$el.load 'home_content', =>
      @renderTool()
      @delegateEvents()
    
  renderTool: ->
    @$el.find('#tile').append "<div class='tool'>#{@model.get 'name'}</div>"

  clickTile: ->
    app.navigate 'tool', {trigger: true}

