class Cu.View.ToolContent extends Backbone.View
  id: 'fullscreen'

  initialize: ->
    boxUrl = window.boxServer
    @model.publishToken (token) =>
      obj =
        source:
          apikey: window.user.effective.apiKey
          url: "#{boxUrl}/#{@model.get 'box'}/#{token}"

      frag = encodeURIComponent JSON.stringify(obj)
      @$el.html """<iframe src="#{boxUrl}/#{@model.get 'box'}/#{token}/http/##{frag}"></iframe>"""
