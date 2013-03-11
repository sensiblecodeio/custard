#= require namespace
# Must come before any model that uses the mixin
#= require model/boxable
#= require model/tool
#= require model/view
#= require_tree model
#= require_tree router
#= require_tree view

$ ->
  window.app = new Cu.Router.Main()
  Backbone.history.start {pushState: on}

  if Backbone.history and Backbone.history._hasPushState
    $(document).delegate "a:not([href^=http])", "click", (evt) ->
      unless $(@).is '[data-nonpushstate]'
        unless evt.metaKey or evt.ctrlKey
          href = $(@).attr "href"
          evt.preventDefault()
          window.app.navigate href, trigger: true

class Cu.AppView
  constructor: (@selector) ->

  showView: (view) ->
    @currentView?.close()
    @currentView = view
    @currentView.render()

    $(@selector).html @currentView.el

  hideView: (view) ->
    @currentView?.close()
    $(@selector).empty()
    
