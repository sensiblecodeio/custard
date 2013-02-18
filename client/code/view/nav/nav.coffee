class Cu.View.Nav extends Backbone.View
  el: 'nav'

  initialize: ->
    @siteLinks = new Cu.View.SiteLinks()
    @$el.append @siteLinks.render().el
