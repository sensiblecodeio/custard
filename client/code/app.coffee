#= require namespace
#= require_tree model
#= require_tree router
#= require_tree view

$ ->
  window.app = new Cu.Router.Main()
  Backbone.history.start {pushState: on}

  if Backbone.history and Backbone.history._hasPushState
    $(document).delegate "a", "click", (evt) ->
      href = $(@).attr("href")
      console.warn "NO HREF", @ unless href
      protocol = @protocol + "//"
      if href.slice(protocol.length) isnt protocol
        evt.preventDefault()
        window.app.navigate href, trigger: true

class Cu.AppView
  constructor: (@selector) ->

  showView: (view) ->
    @currentView?.close()
    @currentView = view
    @currentView.render()

    $(@selector).html @currentView.el
