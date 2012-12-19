#= require namespace
#= require_tree model
#= require_tree router
#= require_tree view

$ ->
  window.app = new Cu.Router.Main()
  Backbone.history.start {pushState: on}

class Cu.AppView
  showView: (view) ->
    @currentView?.close()
    @currentView = view
    @currentView.render()

    $('#content').html @currentView.el
