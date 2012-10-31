window.ToolContentView = class HomeContentView extends Backbone.View
  el: '#content'

  initialize: ->
    @render()

  render: ->
    @$el.empty()
    @model.install =>
      @model.setup (stuff) => @$el.html stuff
