class Cu.View.Terms extends Backbone.View
  className: "terms"

  render: ->
    @el.innerHTML = JST['terms']()
    @
