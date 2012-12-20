class Cu.View.Title extends Backbone.View
  render: ->
    @$el.html """<h2>#{@options.text}</h2>"""
    @
