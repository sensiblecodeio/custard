class Cu.View.Help extends Backbone.View
  className: "help"

  initialize: (options) ->
    @options = options || {}

  events:
    'click nav a': 'navClick'
    'click a[href^="#"]': 'navClick'

  render: ->
    @el.innerHTML = JST[@options.template]
      user: window.user.effective
    setTimeout @makePrettyLike, 100

    # redirect old URL to new page
    if window.location.pathname == "/help/twitter-search/" and window.location.hash == "#faq"
      app.navigate "/help/twitter-faq", trigger: true
    @

  navClick: (e) ->
    e.preventDefault()
    if $(e.target.hash).length > 0
      app.navigate(window.location.pathname + e.target.hash)
      $('html, body').animate
        scrollTop: $(e.target.hash).offset().top - 70
      , 250

  makePrettyLike: =>
    prettyPrint() # syntax-highlight code blocks
    $('nav.well').affix({offset: 110}) # fixed position for table of contents
    $('body').scrollspy('refresh') # highlight links in table of contents on scroll
    $(window).trigger('scroll') # fake a scroll event to highlight the current link
    $('body').on 'activate', @foldUnfold
    @foldUnfold()

  foldUnfold: ->
    $('.nav-list li').each ->
      $li = $(this)
      if $('.active', $li).length or $li.is('.active')
        $li.children('.nav-list:hidden').slideDown()
      else
        $li.find('.nav-list:visible').slideUp()
