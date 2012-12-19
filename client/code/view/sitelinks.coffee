class Cu.View.SiteLinks extends Backbone.View
  tagName: 'ul'
  id: 'sitelinks'

  events:
    'click #userlink': 'userClicked'

  render: ->
    @el.innerHTML = JST.sitelinks window.user.effective
    @

  userClicked: (event) ->
    event.preventDefault()
    $('#userlinks').toggleClass 'open'

