class Cu.View.Journalists extends Backbone.View
  className: "journalists"

  render: ->
    @el.innerHTML = JST['journalists']()
    @$el.css 'max-width', '580px'
    @
