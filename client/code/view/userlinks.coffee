class Cu.View.UserLinks extends Backbone.View
  tagName: 'ul'
  id: 'userlinks'
  className: 'dropdown-menu'

  events:
    'click .btn-primary': 'clickLogout'
    'click #switch-to-this-user': 'clickSwitch'

  clickLogout: ->
    location.href = '/logout'

  clickSwitch: ->
    username = @$el.find('.search-query').val()
    if username != ''
      location.href = "/switch/#{username}/"

  render: ->
    users = []
    @el.innerHTML = JST.userlinks window.user.effective
    @$el.find('.search-query').typeahead({
      source: (query, process) ->
        $.ajax
          url: '/api/user/'
          dataType: 'json'
          success: (latestUsers) ->
            users = for u in latestUsers
              u.shortName
            process users
          error: (jqXHR, textStatus, errorThrown) ->
            process users
        if users.length
          users
    })
    @