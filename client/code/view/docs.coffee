class Cu.View.Docs extends Backbone.View
  className: "docs"

  render: ->
    @el.innerHTML = JST['docs']()
    @