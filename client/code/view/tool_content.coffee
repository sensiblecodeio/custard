window.ToolContentView = class HomeContentView extends Backbone.View
  el: '#content'

  initialize: ->
    @render()

  render: ->
    @$el.html """<p class="loading">Loading #{@model.get 'name'} tool</p>"""
    @model.install =>
      @model.setup (stuff) => @$el.html stuff
