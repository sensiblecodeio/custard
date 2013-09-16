class Cu.View.CreateProfile extends Backbone.View
  className: "create-profile"

  events:
    'click .btn-primary': 'createProfile'
    'keyup #displayname': 'keyupDisplayName'
    'keyup #shortname': 'keyupShortName'
    'blur #shortname': 'keyupDisplayName'

  render: ->
    @el.innerHTML = JST['create-profile']()
    @

  keyupShortName: (e) ->
    if $(e.target).val() == ''
      $(e.target).removeClass('edited')
    else
      $(e.target).addClass('edited')

  keyupDisplayName: ->
    # "is" is a reserved word in coffeescript, so we use
    # long form method notation for the .is() jQuery function!!
    if not $('#shortname')['is']('.edited')
      username = $('#displayname').val()
      username = username.toLowerCase().replace(/[^a-zA-Z0-9-.]/g, '')
      $('#shortname').val(username)

  createProfile: (e) ->
    e.preventDefault()
    accountLevel = $('#accountlevel').val()
    displayName = $('#displayname').val()
    shortName = $('#shortname').val()
    email = $('#email').val()
    $button = $(e.target)
    if shortName!=''
      $button.attr('disabled', true).addClass('loading').html('Creating Profile&hellip;')
      $.ajax
        url: "#{location.protocol}//#{location.host}/api/user/"
        data:
          accountLevel: accountLevel
          shortName: shortName
          displayName: displayName
          email: email
        type: 'POST'
        dataType: 'json'
        success: (newProfile) =>
          url = "#{location.protocol}//#{location.host}/set-password/#{newProfile.token}"
          @$el.children('form').html("""<h4>New profile &ldquo;#{newProfile.shortName}&rdquo; created.</h4>
          <p>They can set their password here:</p>
          <p><input type="text" class="input-xxlarge" value="#{url}" /></div>""")
        error: (jqxhr, textStatus, errorThrown) ->
          if errorThrown == 'Forbidden'
            alert("Hmmm... computer says no. Is your API key a valid staff key?")
          else
            alert("#{textStatus}: #{errorThrown}")
          $button.attr('disabled', false).removeClass('loading').html('<i class="icon-ok space"></i> Try Again')
    else
      alert('Sorry. You must supply a staff API key and a shortName.')
