class Cu.View.ViewContent extends Backbone.View
  id: "fullscreen"

  initialize: ->
    boxurl = "#{window.boxServer}/#{@options.dataset.get 'box'}"
    @options.dataset.publishToken (token) =>
      @$el.html """<iframe src="#{boxurl}/#{token}/http/#{@options.tool.get 'name'}-tool##{window.user.effective.apiKey}"></iframe>"""

