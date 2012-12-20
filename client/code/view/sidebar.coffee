class Cu.View.SideBar extends Backbone.View
  tagName: 'ul'
  id: 'sidebar'
  events:
    'click li': 'clickedLink'

  render: ->
    @el.innerHTML = JST.sidebar()
    loc = window.location.pathname
    if loc == '/' or /\/dataset/.test(loc)
      @$el.find('.my-datasets a').addClass('active')
    else if /\/tool/.test(loc)
      @$el.find('.my-tools a').addClass('active')
    @

  clickedLink: (e) ->
    e.preventDefault()
    $a = $(event.target).closest('a')
    $a.addClass('active').parent().siblings().children('a').removeClass('active')
    window.app.navigate $a.attr('href'), {trigger: true}


