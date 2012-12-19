class Cu.View.SideBar extends Backbone.View
  tagName: 'ul'
  id: 'sidebar'

  render: ->
    @el.innerHTML = JST.sidebar()
    @
