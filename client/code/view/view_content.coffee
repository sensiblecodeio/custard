class Cu.View.ViewContent extends Backbone.View

  initialize: ->
    # Need a view name here
    boxurl = "#{window.boxServer}/#{@model.get 'box'}"
    @model.publishToken (token) =>
      @$el.html """<iframe src="#{boxurl}/#{token}/http/"></iframe>"""

