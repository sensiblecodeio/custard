class Cu.View.SignUp extends Backbone.View
  className: 'sign-up'
  events:
    'click #go': 'go'

  render: ->
    @el.innerHTML = JST['sign-up']()

  go: (e) ->
    e.preventDefault()
    $('#go').addClass('loading').html('Creating Account&hellip;')

    model = new Cu.Model.User
      shortName: $('#shortName').val()
      email: $('#email').val()
      displayName: $('#displayName').val()

    model.on "invalid", (model, error) ->
      alert(error)

    model.save {},
      success: (model, response, options) ->
        console.log model, response, options
      error: (model, response, options) ->
        console.warn model, response, options
        for key of response
          $("##{key}").after("""<span class="help-inline">#{response[key]}</span>""").parents('.control-group').addClass('error')

    #$('form').hide()
    #$('#thanks').show()
