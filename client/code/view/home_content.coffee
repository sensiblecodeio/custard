class Cu.View.HomeContent extends Backbone.View
  events:
    'click #tools .metro-tile': 'clickTool'

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

  clickTool: (event_) ->
    window.app.navigate "tool/#{@model.get 'name'}", {trigger: true}


