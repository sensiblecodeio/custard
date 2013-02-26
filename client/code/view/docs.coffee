class Cu.View.Docs extends Backbone.View
  className: "docs"

  events:
    'click nav a': 'navClick'
    'click a[href^="#"]': 'navClick'

  render: ->
    @el.innerHTML = JST[@template]
      user: window.user.effective
    $ ->
      prettyPrint()
      $('nav.well').affix({offset: 120})
    @

  navClick: (e) ->
    e.preventDefault()
    if $(e.target.hash).length > 0
      $('html, body').animate
        scrollTop: $(e.target.hash).offset().top - 70
      , 250

class Cu.View.DeveloperDocs extends Cu.View.Docs
  template: 'docs-developer'

class Cu.View.CorporateDocs extends Cu.View.Docs
  template: 'docs-corporate'