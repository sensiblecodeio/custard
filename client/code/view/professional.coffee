# The homepage contains "sections" for free, medium and
# professional services markets. This view handles all three,
# showing the correct section (if required) by looking at
# the @options.section value passed from the router.

class Cu.View.Professional extends Backbone.View
  className: 'professional'
  events:
    'click #faq h3': 'showFaq'
    'click .carousel-nav a': 'scrollCarousel'
    'submit #request form': 'submitRequest'

  render: ->
    @el.innerHTML = JST['professional']()
    setTimeout =>
      @setUpCarousel()
    , 200
    @

  close: ->
    $(window).off('resize.carousel')

  setUpCarousel: ->
    if $('.carousel-wrapper').length == 0
      $(window).off('resize.carousel')
      return true

    $wrapper = $('.carousel-wrapper')
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

  submitRequest: (e) ->
    e.preventDefault()
    $('#request form :submit').attr('disabled', true).addClass('loading').val('Saving your details\u2026')
    values = {
      name: $('#id_name').val(),
      phone: $('#id_phone').val(),
      email: $('#id_email').val(),
      description: $('#id_description').val()
    }
    dataRequest = new Cu.Model.DataRequest values
    dataRequest.on 'invalid', @displayErrors, @
    dataRequest.save()

  displayErrors: (model_, errors) ->
    $('#request form :submit').removeClass('loading').attr('disabled', false).val('Call me back')
    for key of errors
      $("#id_#{key}").prev().text("#{errors[key]}:").parent('.control-group').addClass('error')
