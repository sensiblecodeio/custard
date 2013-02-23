class Cu.View.CreateProfile extends Backbone.View
  className: "create-profile"

  events:
    'click .btn-primary': 'createProfile'

  render: ->
    @el.innerHTML = JST['create-profile']()
    @

  createProfile: (e) ->
    e.preventDefault()
    displayName = $('#displayname').val()
    shortName = $('#shortname').val()
    email = $('#email').val()
    $button = $(e.target)
    if shortName!=''
      $button.attr('disabled', true).addClass('loading').html('Creating Profile&hellip;')
      $.ajax
        url: "#{location.protocol}//#{location.host}/api/#{shortName}/"
        data:
          shortName: shortName
          displayName: displayName
          email: email
        type: 'POST'
        dataType: 'json'
        success: (newProfile) =>
          url = "#{location.protocol}//#{location.host}/set-password/#{newProfile.token}"
          @$el.children('form').html "<div class=\"alert alert-success\"><strong>New profile &ldquo;#{newProfile.shortName}&rdquo; created.</strong><br/>They can set their password <a href=\"#{url}\" title=\"#{url}\">here</a>.</div>"
        error: (jqxhr, textStatus, errorThrown) ->
          if errorThrown == 'Forbidden'
            alert("Hmmm... computer says no. Is your API key a valid staff key?")
          else
            alert("#{textStatus}: #{errorThrown}")
          $button.attr('disabled', false).removeClass('loading').html('<i class="icon-ok space"></i> Try Again')
    else
      alert('Sorry. You must supply a staff API key and a shortName.')
