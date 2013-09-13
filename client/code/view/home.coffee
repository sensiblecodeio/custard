# The homepage contains "sections" for free, medium and
# professional services markets. This view handles all three,
# showing the correct section (if required) by looking at
# the @options.section value passed from the router.

class Cu.View.Home extends Backbone.View
  className: 'home'

  render: ->
    @el.innerHTML = JST['home']()
    @tableXtractFlash()
    @

  tableXtractFlash: ->
    html = """<p class="container">
      <strong>Automatically and accurately extract tables from PDFs</strong>
      with our new Table Xtract tool
      <a class="btn btn-warning btn-small pull-right" href="/tools/tablextract">Learn more <i class="icon-chevron-right"></i></a>
    </p>"""
    $('<div>').attr('id', 'table-xtract-flash').addClass('alert alert-warning')
      .hide().html(html).insertAfter('body > header').slideDown()
      .find('a').on 'click', ->
        _gaq.push ['_trackEvent', 'table-xtract', 'homepage-flash-click']

  close: ->
    $('#table-xtract-flash').hide()
