class Cu.View.AdminContent extends Backbone.View
  events:
    'click .btn-primary': 'createProfile'

  el: '#content'

  initialize: ->
    @render()

  render: ->
    @$el.empty()
    @$el.load '/tpl/admin_content'

  # Temporary Cobalt creation

  # Request to Cobalt here?
  createCobaltProfile: (profile, callback) ->
    $.ajax
      url: "#{window.boxServer}/#{profile.shortName}"
      type: 'POST'
      dataType: 'json'
      data:
        apikey: window.user.real.apiKey
        displayname: profile.displayName
        email: profile.email[0]
        newApikey: profile.apikey
      success: (cobaltProfile) =>
        callback cobaltProfile

  createProfile: (e) ->
    e.preventDefault()
    displayName = $('#displayname').val()
    shortName = $('#shortname').val()
    email = $('#email').val()
    $button = $(e.target)
    if shortName!=''
      $button.attr('disabled', true).addClass('loading').html('Creating Profile&hellip;')
      $.ajax
        url: "#{location.origin}/api/#{shortName}/"
        data:
          shortName: shortName
          displayName: displayName
          email: email
        type: 'POST'
        dataType: 'json'
        success: (newProfile) =>
          console.log newProfile
          @createCobaltProfile newProfile, (cobaltProfile) =>
            url = "#{location.origin}/set-password/#{newProfile.token}"
            @$el.children('form').html "<div class=\"alert alert-success\"><strong>New profile &ldquo;#{newProfile.shortName}&rdquo; created.</strong><br/>They can set their password <a href=\"#{url}\" title=\"#{url}\">here</a>.</div>"
        error: (jqxhr, textStatus, errorThrown) ->
          if errorThrown == 'Forbidden'
            alert("Hmmm... computer says no. Is your API key a valid staff key?")
          else
            alert("#{textStatus}: #{errorThrown}")
          $button.attr('disabled', false).removeClass('loading').html('<i class="icon-ok space"></i> Try Again')
    else
      alert('Sorry. You must supply a staff API key and a shortName.')
