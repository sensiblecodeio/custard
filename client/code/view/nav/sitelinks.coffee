class Cu.View.SiteLinks extends Backbone.View
  tagName: 'ul'

  render: ->
    @el.innerHTML = JST.sitelinks window.user.effective
    @
