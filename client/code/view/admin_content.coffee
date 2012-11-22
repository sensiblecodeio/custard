window.AdminContentView = class AdminContentView extends Backbone.View
  events:
    'click .btn-primary': 'createProfile'

  el: '#content'

  initialize: ->
    @render()

  render: ->
    @$el.empty()
    @$el.load '/tpl/admin_content'

  createProfile: (e) ->
    e.preventDefault()
    apikey = $('#apikey').val()
    displayname = $('#displayname').val()
    shortname = $('#shortname').val()
    email = $('#email').val()
    $button = $(e.target)
    if apikey!='' or shortname!=''
      $button.attr('disabled', true).addClass('loading').html('Creating Profile&hellip;')
      $.ajax
        url: "http://boxecutor-dev-1.scraperwiki.net/#{shortname}/"
        data:
          apikey: apikey
          shortname: shortname
          displayname: displayname
          email: email
        type: 'POST'
        dataType: 'json'
        success: (newProfile) =>
          console.log newProfile
          url = "#{location.origin}/set-password/#{newProfile.token}"
          @$el.children('form').html "<div class=\"alert alert-success\"><strong>New profile &ldquo;#{newProfile.shortname}&rdquo; created.</strong><br/>They can set their password <a href=\"#{url}\" title=\"#{url}\">here</a>.</div>"
        error: (jqxhr, textStatus, errorThrown) ->
          if errorThrown == 'Forbidden'
            alert("Hmmm... computer says no. Is your API key a valid staff key?")
          else
            alert("#{textStatus}: #{errorThrown}")
          $button.attr('disabled', false).removeClass('loading').html('<i class="icon-ok space"></i> Try Again')
    else
      alert('Sorry. You must supply a staff API key and a shortname.')