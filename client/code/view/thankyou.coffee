class Cu.View.Thankyou extends Backbone.View
  className: 'thankyou'

  render: ->
    options =
      hasAccount: false
    if window.user?.real
      options.hasAccount = true
    @el.innerHTML = JST['thankyou'] options
    @

