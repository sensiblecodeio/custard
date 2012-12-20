class Cu.View.ViewContent extends Backbone.View

  id: "fullscreen"

  initialize: ->
    # Need a view name here
    console.log @
    boxurl = "#{window.boxServer}/#{@model.get 'box'}"
    @model.publishToken (token) =>
      @$el.html """<iframe src="#{boxurl}/#{token}/http/#{@options.viewName}-tool"></iframe>"""

