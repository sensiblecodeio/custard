#= require namespace
#= require_tree model
#= require_tree router
#= require_tree view

$ ->
  window.app = new Cu.Router.Main()
  Backbone.history.start {pushState: on}
