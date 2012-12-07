class Cu.View.SetPassword extends Backbone.View
  events:
    'click .btn-primary': 'setPassword'

  el: '#content'

  initialize: ->
    @render()

  render: ->
    @$el.empty()
    @$el.load '/tpl/setpassword_content'

  setPassword: (e) ->
    e.preventDefault()
    password = $('#password').val()
    token = location.pathname.split('/')
    token = token[token.length-1]
    $button = $(e.target)
    if password!=''
      $button.attr('disabled', true).addClass('loading').html('Setting Password&hellip;')
      $.ajax
        url: "http://boxecutor-dev-1.scraperwiki.net/token/#{token}"
        data:
          password: password
        type: 'POST'
        dataType: 'json'
        success: (profile) =>
          @$el.children('form').html "<div class=\"alert alert-success\"><strong>Thanks for setting your password.</strong></div>"
          $('#header h2 a').text(profile.displayname)
        error: (jqxhr, textStatus, errorThrown) ->
          if errorThrown == 'Forbidden'
            alert("Hmmm... computer says no. Is your API key a valid staff key?")
          else
            alert("#{textStatus}: #{errorThrown}")
          $button.attr('disabled', false).removeClass('loading').html('<i class="icon-ok space"></i> Try Again')
    else
      alert 'Sorry. You must supply a password.'
