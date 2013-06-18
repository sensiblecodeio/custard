# The homepage contains "sections" for free, medium and
# professional services markets. This view handles all three,
# showing the correct section (if required) by looking at
# the @options.section value passed from the router.

class Cu.View.Home extends Backbone.View
  className: 'home'
  events:
    'click #use-cases > ul li': 'showUseCase'
    'click #faq h3': 'showFaq'
    'click .carousel-nav a': 'scrollCarousel'

  render: ->
    @el.innerHTML = JST['home']()
    @$el.find('#use-cases section').hide()

    # have they requested a particular section?
    if @options?.section
      $section = $("##{@options.section}", @$el)
      $section.show()
      $tab = $("#use-cases > ul li[data-section='#{@options.section}']", @$el)
      @activateTab $tab

      setTimeout =>
        @setUpCarousel($section)
        $('html, body').animate
          scrollTop: $('#use-cases', @$el).offset().top - 20
        , 250
      , 200
    @

  close: ->
    $(window).off('resize.carousel')

  activateTab: ($tab) ->
    $tab.addClass('active').removeClass('inactive').children('img').attr 'src', ->
      $(this).attr('src').replace('.png', '-selected.png')

    @deactivateTab $tab.siblings()

  deactivateTab: ($tab) ->
    $tab.addClass('inactive').removeClass('active').children('img').attr 'src', ->
      $(this).attr('src').replace('-selected.png', '.png')

  showUseCase: (e) ->
    e.preventDefault()
    $tab = $(e.currentTarget)
    sectionId = $tab.attr('data-section')
    $section = $("##{sectionId}", @$el)

    if $section.is(':visible')
      # change the url
      app.navigate "/", trigger: false
      # hide the current section
      @deactivateTab $tab
      $section.slideUp()
      # stop listening for resize events
      $(window).off('resize.carousel')
    else
      # change the url
      app.navigate "/#{sectionId}", trigger: false
      _gaq.push ['_trackEvent', 'show-use-case', sectionId]
      visibleSections = $('#use-cases section:visible', @$el)
      if visibleSections.length
        # another section is already visible, hide it first
        visibleSections.slideUp =>
          @activateTab $tab
          $section.slideDown =>
            @setUpCarousel($section)
      else
        # no visible sections yet, just show the one they want
        @activateTab $tab
        $section.slideDown =>
          @setUpCarousel($section)

  setUpCarousel: ($section) ->
    if $('.carousel-wrapper', $section).length == 0
      $(window).off('resize.carousel')
      return true

    $wrapper = $('.carousel-wrapper', $section)
    $carousel = $wrapper.children '.carousel'
    $firstCaseStudy = $carousel.children().eq 0
    $carouselNav = $('.carousel-wrapper').siblings '.nav'

    $wrapper.css 'height', $firstCaseStudy.height()
    $carousel.scrollLeft 0

    if $carouselNav.length == 0
      $nav = $('<ul class="nav nav-pills carousel-nav">').insertBefore $wrapper.prev()
      $carousel.children().each (i) ->
        $nav.append '<li><a>' + (i+1) + '</a></li>'
      $nav.children().eq(0).addClass('active')

    lazyResize = _.debounce =>
      @scrollCarousel $wrapper
    , 200

    $(window).on 'resize.carousel', lazyResize

  scrollCarousel: (e) ->
    if e.currentTarget
      $link = $(e.currentTarget)
      $li = $link.parent()
      $wrapper = $li.parent().siblings('.carousel-wrapper')
      $carousel = $wrapper.children '.carousel'
    else
      $wrapper = $(e)
      $carousel = $(e).children('.carousel')
      $link = $wrapper.siblings('.carousel-nav').find('.active a')
      $li = $link.parent()

    $li.addClass('active').siblings('.active').removeClass('active')

    eq = $li.prevAll().length
    $target = $carousel.children().eq eq

    $wrapper.animate
      scrollLeft: eq * $target.width()
      height: $target.height()
    , 250

  showFaq: (e) ->
    $h3 = $(e.currentTarget)
    $p = $h3.next('p')
    if $h3.is('.open')
      $h3.removeClass('open')
      $p.slideUp()
    else
      $h3.addClass('open').siblings('.open').removeClass('open').next('p').slideUp()
      $p.slideDown()
