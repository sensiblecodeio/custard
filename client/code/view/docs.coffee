class Cu.View.Help extends Backbone.View
  className: "help"

  events:
    'click nav a': 'navClick'
    'click a[href^="#"]': 'navClick'

  render: ->
    @el.innerHTML = JST[@options.template]
      user: window.user.effective
    setTimeout @makePrettyLike, 100
    @

  navClick: (e) ->
    e.preventDefault()
    if $(e.target.hash).length > 0
      app.navigate(window.location.pathname + e.target.hash)
      $('html, body').animate
        scrollTop: $(e.target.hash).offset().top - 70
      , 250

  makePrettyLike: ->
    prettyPrint() # syntax-highlight code blocks
    $('nav.well').affix({offset: 110}) # fixed position for table of contents
    $('body').scrollspy('refresh') # highlight links in table of contents on scroll
    $(window).trigger('scroll') # fake a scroll event to highlight the current link
