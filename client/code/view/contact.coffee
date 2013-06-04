class Cu.View.Contact extends Backbone.View
  className: "contact"

  render: ->
    @el.innerHTML = JST['contact']()
    @
