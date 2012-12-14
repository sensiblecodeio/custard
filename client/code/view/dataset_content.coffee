class Cu.View.DatasetContent extends Backbone.View
  el: '#content'

  initialize: ->
    @$el.empty()
    $('body').attr 'class', 'tool' # TODO: change to dataset CSS

    boxurl = "#{window.boxServer}/#{@model.get 'box'}"
    @model.publishToken (token) =>
      $('#content').html """<iframe src="#{boxurl}/#{token}/http/"></iframe>"""

