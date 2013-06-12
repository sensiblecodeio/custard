class Cu.View.About extends Backbone.View
  className: "about"

  render: ->
    @el.innerHTML = JST['about']()
    @
