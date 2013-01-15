class Cu.View.UserLinks extends Backbone.View
  tagName: 'ul'
  id: 'userlinks'
  className: 'dropdown-menu'

  events:
    'click .btn-primary': 'clickLogout'
    'focus #context-search input': 'focusContextSearch'
    'blur #context-search input': 'blurContextSearch'
    'keyup #context-search input': 'keyupContextSearch'

  clickLogout: ->
    location.href = '/logout'

  clickSwitch: ->
    username = @$el.find('.search-query').val()
    if username != ''
      location.href = "/switch/#{username}/"

  focusContextSearch: ->
    $('#context-search').addClass 'focussed'
    $('#context-search').addClass 'loading'
    $.ajax
      url: '/api/user/'
      dataType: 'json'
      success: (latestUsers) ->
        $('#context-search').removeClass 'loading'
        window.users = for user in latestUsers
          user
      error: (jqXHR, textStatus, errorThrown) ->
        $('#context-search').removeClass 'loading'
        console.warn 'Could not query users API', errorThrown

  blurContextSearch: ->
    $('#context-search').removeClass 'focussed'

  keyupContextSearch: (e) ->
    li = $('#context-search')
    input = li.find('input')
    t = input.val()
    results = $('.context-search-result')
    if t != ''
      results.remove()
      tophits = []
      runnersup = []
      if window.users?
        for user in window.users
          if user.shortName in [ window.user.effective.shortName, window.user.real.shortName ]
            continue
          m1 = if user.displayName? then user.displayName.toLowerCase().search(t.toLowerCase()) else -1
          m2 = if user.shortName? then user.shortName.toLowerCase().search(t.toLowerCase()) else -1
          if m1 == 0 or m2 == 0
            tophits.push user
          else if m1 > 0 or m2 > 0
            runnersup.push user
        for runnerup in runnersup
          view = new Cu.View.ContextSearchLink runnerup
          li.after view.render().el
        for tophit in tophits
          view = new Cu.View.ContextSearchLink tophit
          li.after view.render().el
      else
        console.warn 'Could not query users API'
    else if t == ''
      results.remove()

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

    @
