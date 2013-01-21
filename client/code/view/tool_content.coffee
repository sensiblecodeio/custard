class Cu.View.ToolContent extends Backbone.View
  id: 'fullscreen'

  initialize: ->
    boxUrl = window.boxServer
    @model.publishToken (token) =>
      obj = {}
      obj.dataset =
        apikey: window.user.effective.apiKey
        box_url: "#{boxUrl}/#{@model.get 'box'}/#{token}"

      frag = encodeURIComponent JSON.stringify(obj)
      @$el.html """<iframe src="#{boxUrl}/#{@model.get 'box'}/#{token}/http/##{frag}"></iframe>"""
