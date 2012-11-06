window.HomeContentView = class HomeContentView extends Backbone.View
  events:
    'click .metro-tile': 'clickTile'

  el: '#content'

  initialize: ->
    @render()

  render: ->
    @$el.empty()
    @$el.load '/home_content', =>
      @renderTool()
    
  renderTool: ->
    @$el.find('#tools .metro-tile').first().addClass(@model.get 'name').find('h3').text @model.get 'name'

  clickTile: (event_) ->
    window.app.navigate "tool/#{@model.get 'name'}", {trigger: true}

