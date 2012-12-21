class Cu.View.FourOhFour extends Backbone.View
  className: "fourohfour"

  render: ->
    @el.innerHTML = JST['fourohfour']()
    @