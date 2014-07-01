class Cu.View.ResetPassword extends Backbone.View
  className: "reset-password"

  events:
    'click #go': 'sendResetEmail'

  render: ->
    @el.innerHTML = JST['reset-password'] window.user?.real
    $('#forgotten-shortname', @$el).popover(
      title: "No problem!"
      content: 'Email us for a reset link: <a href="mailto:hello@scraperwiki.com">hello@scraperwiki.com</a>'
      html: true
      placement: 'right'
    ).on('click', (e) ->
      e.preventDefault()
      e.stopPropagation()
    ).css('cursor', 'pointer')
    @

  sendResetEmail: (e) ->
    e.preventDefault()
    query = $('#query').val()
    @$el.find('.alert').remove()
    @$el.find('.control-group').removeClass('error')
    if query == ''
      @$el.find('.control-group').addClass('error').children('label').text('You must supply a username:').next().focus()
    else
      $('#go').attr('disabled', true).addClass('loading')
      $.ajax
        url: "#{location.protocol}//#{location.host}/api/user/reset-password/"
        type: 'POST'
        data:
          query: query
        dataType: 'json'
        success: (data) =>
          $('form', @$el).prepend """<div class="alert alert-success"><strong>Password reset link sent.</strong> Please check your emails.</a></div>"""
          $('#go').attr('disabled', false).removeClass('loading')
          _gaq.push ['_trackEvent', 'set-password', 'success', query]
        error: (jqxhr, textStatus, errorThrown) =>
          if jqxhr.status == 404
            msg = """<div class="alert"><strong>Hmmm. That username could not be found.</strong></div>"""
          else
            msg = """<div class="alert alert-error"><strong>Hmmm. Something went wrong.</strong> Email <a href="mailto:hello@scraperwiki.com">hello@scraperwiki.com</a> and we&rsquo;ll email you a password reset link manually.</div>"""
          $('form', @$el).prepend msg
          $('#go').attr('disabled', false).removeClass('loading')
          _gaq.push ['_trackEvent', 'set-password', 'failure', query]
