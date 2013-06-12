# The homepage contains "sections" for free, medium and
# professional services markets. This view handles all three,
# showing the correct section (if required) by looking at
# the @options.section value passed from the router.

class Cu.View.Home extends Backbone.View
  className: 'home'
  events:
    'click #use-cases a': 'showUseCase'

  render: ->
    @el.innerHTML = JST['home']()
    @$el.find('.use-case').hide()

    # have they requested a particular section?
    if @options?.section
      $("##{@options.section}", @$el).show()
      $("#use-cases a[href='##{@options.section}']", @$el).parent()
        .addClass('active').siblings().addClass('inactive')

      setTimeout =>
        $('html, body').animate
          scrollTop: $('#use-cases', @$el).offset().top - 20
        , 250
      , 200
    @

  showUseCase: (e) ->
    e.preventDefault()
    $tab = $(e.currentTarget)
    sectionId = $tab.attr('href').replace('#', '')
    $section = $("##{sectionId}", @$el)

    if $section.is(':visible')
      # change the url
      app.navigate "/", trigger: false
      # hide the current section
      $tab.parent().removeClass('active').siblings().removeClass 'inactive'
      $section.slideUp()
    else
      # change the url
      app.navigate "/#{sectionId}", trigger: false
      _gaq.push ['_trackEvent', 'show-use-case', sectionId]
      if $('.use-case:visible', @$el).length
        # another section is already visible, hide it first
        $('section:visible', @$el).slideUp =>
          $tab.parent().removeClass('inactive').addClass('active')
            .siblings().removeClass('active').addClass('inactive')
          $section.slideDown()
      else
        # no visible sections yet, just show the one they want
        $tab.parent().addClass('active').siblings().addClass('inactive')
        $section.slideDown()
