class Cu.View.Subscribe extends Backbone.View
  className: 'subscribe'

  render: ->
    @el.innerHTML = JST['subscribe'] @options
