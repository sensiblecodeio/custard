class Cu.View.SideBar extends Backbone.View
  tagName: 'ul'
  id: 'sidebar'
  events:
    'click li': 'clickedLink'

  render: ->
    @el.innerHTML = JST.sidebar()
    @

  clickedLink: (e) ->
    e.preventDefault()
    href = $(event.target).closest('a').attr 'href'
    window.app.navigate href, {trigger: true}


