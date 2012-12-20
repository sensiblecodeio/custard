class Cu.View.UserLinks extends Backbone.View
  tagName: 'ul'
  id: 'userlinks'
  className: 'dropdown-menu'

  events:
    'click .btn-primary': 'clickLogout'

  clickLogout: ->
    location.href = '/logout'

  render: ->
    @el.innerHTML = JST.userlinks()
    @