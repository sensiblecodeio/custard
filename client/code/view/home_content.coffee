window.HomeContentView = class HomeContentView extends Backbone.View
  events:
    'click .metro-tile': 'clickTile'

  el: '#content'

  initialize: ->
    @render()

  render: ->
    @$el.empty()
    @$el.load '/tpl/home_content', =>
      @renderStuff()
    
  renderStuff: ->
    name = @model.get 'name'
    @$el.find('#tools .metro-tile').first().addClass(name).find('h3').text name

  clickTile: (event_) ->
    window.app.navigate "tool/#{@model.get 'name'}", {trigger: true}

