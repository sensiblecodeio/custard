class Cu.View.Pricing extends Backbone.View
  className: 'pricing'

  render: ->
    @el.innerHTML = JST['pricing'] upgrade: @options.upgrade
