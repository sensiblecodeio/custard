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
    $button = $(e.target)

    if $.trim($('#shortname').val()) == ''
      alert('Sorry. You must supply a shortName.')
      return

    $button.attr('disabled', true).addClass('loading').html('Creating Profile&hellip;')

    data =
      accountLevel: $.trim($('#accountlevel').val())
      displayName: $.trim($('#displayname').val())
      shortName: $.trim($('#shortname').val())
      email: $.trim($('#email').val())
    if $.trim($('#defaultcontext').val()) != ''
      data.defaultContext = $.trim($('#defaultcontext').val())

    $.ajax
      url: "#{location.protocol}//#{location.host}/api/user/"
      data: data
      type: 'POST'
      dataType: 'json'
      success: (newProfile) =>
        url = "#{location.protocol}//#{location.host}/set-password/#{newProfile.token}"
        @$el.children('form').html("""<h4>New profile &ldquo;#{newProfile.shortName}&rdquo; created.</h4>
        <p>They can set their password here:</p>
        <p><input type="text" id="password-reset-link" class="input-xxlarge" value="#{url}" /></div>""")
      error: (jqxhr, textStatus, errorThrown) ->
        if errorThrown == 'Forbidden'
          alert("Hmmm... computer says no. Is your API key a valid staff key?")
        else
          alert("#{textStatus}: #{errorThrown}: #{jqxhr.responseText}")
        $button.attr('disabled', false).removeClass('loading').html('<i class="icon-ok space"></i> Try Again')
