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
    if $('#userlinks').hasClass('open')
      $('#userlinks').removeClass 'open'
      $('a[href="#userlinks"]').removeClass 'active'
    else
      $('#userlinks').addClass 'open'
      $('a[href="#userlinks"]').addClass 'active'
      $('#sidebar.open').removeClass 'open'
      $('a[href="#sidebar"]').removeClass 'active'
      # $(document).on('click.userlinks', (e) ->
      #         console.log 'userlinks is open and you clicked the document'
      #         if $('#userlinks').has(e.target).length == 0
      #           console.log 'your click was outside the userlinks menu'
      #           # closeMenu('#' + $m.attr('id'));
      #           $(document).off('.userlinks');
      #           $('#userlinks').removeClass 'open'
      #           $('a[href="#userlinks"]').removeClass 'active'
      #       )

