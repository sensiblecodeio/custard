class Cu.View.Nav extends Backbone.View
  el: '#header nav'

  initialize: ->
    @el.innerHTML = JST.nav window.user.effective
    @