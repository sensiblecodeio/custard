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
    # populate user dropdown menu
    @$el.html JST.userlinks

    # add real user link
    if window.user.effective.shortName != window.user.real.shortName
      view = new Cu.View.ContextLink
        contextUser: window.user.real
        contextActive: false
      @$el.find('.header').after view.render().el

    # add effective user link
    view = new Cu.View.ContextLink
      contextUser: window.user.effective
      contextActive: true
    @$el.find('.header').after view.render().el

    users = []
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