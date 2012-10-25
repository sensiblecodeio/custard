#= require_tree model
#= require_tree router
#= require_tree view

$ ->
  window.app = new MainRouter()
  Backbone.history.start {pushState: on}
