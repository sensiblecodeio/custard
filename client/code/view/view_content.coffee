class Cu.View.ViewContent extends Backbone.View
  id: "fullscreen"

  initialize: ->
    boxUrl = window.boxServer
    @model.publishToken (view_token) =>
      dataset = @model.get 'plugsInTo'
      dataset.publishToken (dataset_token) =>
        obj =
          source:
            apikey: window.user.effective.apiKey
            url: "#{boxUrl}/#{@model.get 'box'}/#{view_token}"
          target:
            url: "#{boxUrl}/#{dataset.get 'box'}/#{dataset_token}"

        frag = encodeURIComponent JSON.stringify(obj)
        @$el.html """<iframe src="#{obj.source.url}/http/##{frag}"></iframe>"""

