class Cu.View.Nav extends Backbone.View
  el: 'nav'

  initialize: ->
    @sideBar = new Cu.View.SideBar()
    @$el.append @sideBar.render().el

    @siteLinks = new Cu.View.SiteLinks()
    @$el.append @siteLinks.render().el

    @userLinks = new Cu.View.UserLinks()
    @$el.append @userLinks.render().el
