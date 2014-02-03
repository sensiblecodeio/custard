class Cu.View.ResetPassword extends Backbone.View
  className: "reset-password"

  events:
    'click #go': 'sendResetEmail'

  render: ->
    @el.innerHTML = JST['reset-password']()
    @

  sendResetEmail: (e) ->
    e.preventDefault()
    shortName = $('#shortname').val()
    @$el.find('.alert').remove()
    @$el.find('.control-group').removeClass('error')
    if shortName == ''
      @$el.find('.control-group').addClass('error').children('label').text('You must supply a username:').next().focus()
    else
      $('#go').attr('disabled', true).addClass('loading')
      $.ajax
        url: "#{location.protocol}//#{location.host}/api/#{shortName}/set-password/"
        type: 'POST'
        dataType: 'json'
        success: (data) =>
          $('form', @$el).prepend """<div class="alert alert-success"><strong>Password reset link sent.</strong> Please check your emails.</a></div>"""
          $('#go').attr('disabled', false).removeClass('loading')
        error: (jqxhr, textStatus, errorThrown) =>
          $('form', @$el).prepend """<div class="alert"><strong>Hmmm. That username could not be found.</strong> Maybe you&rsquo;re trying to <a href="https://classic.scraperwiki.com/accounts/password/reset/">reset a ScraperWiki Classic password?</a></div>"""
          $('#go').attr('disabled', false).removeClass('loading')
