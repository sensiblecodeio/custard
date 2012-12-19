class Cu.View.UserLinks extends Backbone.View
  tagName: 'ul'
  id: 'userlinks'
  className: 'dropdown-menu'

  render: ->
    @el.innerHTML = JST.userlinks()
    @
