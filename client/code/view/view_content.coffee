class Cu.View.ViewContent extends Backbone.View
  id: "fullscreen"

  initialize: ->
    boxUrl = window.boxServer
    @model.publishToken (view_token) =>
      dataset = @model.get 'plugsInTo'
      dataset.publishToken (dataset_token) =>
        obj = {}
        obj.view_apikey = window.user.effective.apiKey
        obj.dataset_box_url = "#{boxUrl}/#{dataset.get 'box'}/#{dataset_token}"
        frag = encodeURIComponent JSON.stringify(obj)
        @$el.html """<iframe src="#{boxUrl}/#{@model.get 'box'}/#{view_token}/http/##{frag}"></iframe>"""

