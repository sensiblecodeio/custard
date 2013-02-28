class Cu.View.Error extends Backbone.View
  className: "error-page"

  render: ->
    @el.innerHTML = JST['error'] error: @options.text
    @
