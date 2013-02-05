class Cu.View.Docs extends Backbone.View
  className: "docs"

  events:
    'click nav a': 'navClick'

  render: ->
    @el.innerHTML = JST['docs']
      user: window.user.effective
    @

  navClick: (e) ->
    e.preventDefault()
    if $(e.target.hash).length > 0
      $('html, body').animate
        scrollTop: $(e.target.hash).offset().top - 70
      , 250