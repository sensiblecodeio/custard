class Cu.View.FourOhFour extends Backbone.View
  className: "fourohfour error-page"

  render: ->
    @el.innerHTML = JST['fourohfour']()
    @
