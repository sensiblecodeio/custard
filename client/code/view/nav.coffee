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
        real = window.user.real
        effective = window.user.effective
        allUsers = users.toJSON()

        staff = real?.isStaff
        switched = real.shortName != effective.shortName
        conventionalSwitch = effective.shortName in _.pluck(allUsers, 'shortName')

        if staff and switched and not conventionalSwitch
          # this is a staff member who has switched into an
          # account they shouldn't normally be able to access
          allUsers.push window.user.effective

        @el.innerHTML = JST.nav
          realUser: real
          effectiveUser: effective
          allUsers: allUsers

  loggedOutNav: ->
    @el.innerHTML = JST.nav()
