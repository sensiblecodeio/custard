class Cu.View.SignUp extends Backbone.View
  className: 'sign-up'
  events:
    'click #go': 'go'

  render: ->
    @el.innerHTML = JST['sign-up']()

  go: ->
    $('#form-container').hide()
    $('#thanks').show()
