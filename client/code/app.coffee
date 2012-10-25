#= require_tree model
#= require_tree router
#= require_tree view

$ ->
  new MainRouter()
  Backbone.history.start()
