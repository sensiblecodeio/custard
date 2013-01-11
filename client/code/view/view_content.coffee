class Cu.View.ViewContent extends Backbone.View
  id: "fullscreen"

  initialize: ->
    boxurl = "#{window.boxServer}/#{@model.get 'box'}"
    @model.publishToken (token) =>
      @$el.html """<iframe src="#{boxurl}/#{token}/http/##{window.user.effective.apiKey}"></iframe>"""

