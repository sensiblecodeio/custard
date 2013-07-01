#= require namespace
# Must come before any model that uses the mixin
#= require model/boxable
#= require model/tool
#= require model/view
#= require_tree model
#= require_tree router
#= require_tree view
#= require shared/code/page-titles

Backbone.View::close = ->
  @off()
  @remove()

Backbone.history.routeCount = 0
Backbone.history.on 'route', ->
  Backbone.history.routeCount += 1
  Backbone.history.firstLoad = false

$ ->
  window.app = new Cu.Router.Main()
  Backbone.history.start {pushState: on}

  window.app.on 'route', ->
    $('body > .alert').not('.permanent').remove()

  if Backbone.history and Backbone.history._hasPushState
    $(document).delegate "a[href]:not([href^=http])", "click", (evt) ->
      unless $(@).is '[data-nonpushstate]'
        unless evt.metaKey or evt.ctrlKey
          href = $(@).attr "href"
          evt.preventDefault()
          window.app.navigate href, trigger: true
          window.scrollTo 0,0

class Cu.AppView
  constructor: (@selector) ->

  showView: (view) ->
    @currentView?.close()
    window.scrollTo 0,0
    @currentView = view
    @currentView.render()

    $(@selector).show().html @currentView.el

  hideView: (view) ->
    @currentView?.close()
    $(@selector).hide().empty()

class Cu.CollectionManager
  @collections: {}

  @get: (klass) ->
    name = klass.name
    if not @collections[name]
      collection = new klass()
      collection.fetch
        success: ->
          collection.trigger 'fetched'
      @.collections[name] = collection
    return @.collections[name]
