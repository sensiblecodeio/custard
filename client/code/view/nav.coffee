class Cu.View.Nav extends Backbone.View
  el: '#header nav'

  initialize: ->
    if 'effective' of window.user
      @loggedInNav()
    else
      @loggedOutNav()
    @

  loggedInNav: ->
    # Make sure we have the latest list of contexts
    # the current user can access.
    users = Cu.CollectionManager.get Cu.Collection.User
    users.fetch
      success: =>
        console.log users
        @el.innerHTML = JST.nav
          realUser: window.user.real
          effectiveUser: window.user.effective
          allUsers: users.toJSON()

  loggedOutNav: ->
    @el.innerHTML = JST.nav()
