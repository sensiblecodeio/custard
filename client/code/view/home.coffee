class Cu.View.Home extends Backbone.View
  className: 'home'

  render: ->
    @el.innerHTML = JST['help-whats-new']()
