class Cu.View.SideBar extends Backbone.View
  tagName: 'ul'
  id: 'sidebar'
  events:
    'click li': 'clickedLink'
    'click #toggle-sidebar-width': 'toggleSidebarWidth'

  render: ->
    @el.innerHTML = JST.sidebar()
    loc = window.location.pathname
    # :TODO: Make this suck less
    if loc == '/' or /\/dataset/.test(loc)
      @$el.find('.my-datasets a').addClass('active')
    else if /\/tool/.test(loc)
      @$el.find('.my-tools a').addClass('active')
    else if /\/docs/.test(loc)
      @$el.find('.help a').addClass('active')
    @

  clickedLink: (e) ->
    $a = $(event.target).closest('a')
    $a.addClass('active').parent().siblings().children('a').removeClass('active')

  toggleSidebarWidth: (e) ->
    e.preventDefault()
    $b = $('body')
    if $b.hasClass 'thin-sidebar'
      $b.removeClass 'thin-sidebar'
      $('#toggle-sidebar-width span').text 'Collapse'
      $('#sidebar a, #toggle-sidebar-width').tooltip 'destroy'
    else
      $b.addClass 'thin-sidebar'
      $('#toggle-sidebar-width span').text('Expand').attr('data-original-title', 'Expand')
      $('#sidebar a, #toggle-sidebar-width').tooltip
        animation: false
        placement: 'right'
