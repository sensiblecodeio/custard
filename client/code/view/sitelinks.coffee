class Cu.View.SiteLinks extends Backbone.View
  tagName: 'ul'
  id: 'sitelinks'

  events:
    'click #userlink': 'userClicked'

  render: ->
    @el.innerHTML = JST.sitelinks window.user.effective
    @

  userClicked: (event) ->
    # TODO: abstract this out
    event.preventDefault()
    event.stopPropagation()
    if $('#userlinks').hasClass('open')
      $('#userlinks').removeClass 'open'
      $('a[href="#userlinks"]').removeClass 'active'
    else
      $('#userlinks').addClass 'open'
      $('a[href="#userlinks"]').addClass 'active'
      $('#sidebar.open').removeClass 'open'
      $('a[href="#sidebar"]').removeClass 'active'
      $('body').on 'click.userlinks', (e) ->
        if $('#userlinks').has(e.target).length == 0
          $('body').off('.userlinks');
          $('#userlinks').removeClass 'open'
          $('a[href="#userlinks"]').removeClass 'active'

