class Cu.View.SignUp extends Backbone.View
  className: 'sign-up'
  events:
    'click #go': 'go'

  render: ->
    @el.innerHTML = JST['sign-up']()

  go: (e) ->
    e.preventDefault()
    $('#go', @$el).addClass('loading').html('Creating Account&hellip;')
    
    @cleanUpForm()

    model = new Cu.Model.User

    model.save
      shortName: $('#shortName').val()
      email: $('#email').val()
      displayName: $('#displayName').val()
    ,
      success: (model, response, options) ->
        console.log model, response, options
        $('form').hide()
        $('#thanks').show()
      error: (model, response, options) ->
        console.warn model, response, options
        $('#go', @$el).removeClass('loading').html('<i class="icon-ok space"></i> Create Account')
        for key of response
          $("##{key}").after("""<span class="help-inline">#{response[key]}</span>""").parents('.control-group').addClass('error')

    #$('form').hide()
    #$('#thanks').show()

  cleanUpForm: ->
    $('.control-group.error', @$el).removeClass('error').find('.help-inline').remove()
