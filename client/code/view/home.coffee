class Cu.View.Home extends Backbone.View
  className: 'home'

  initialize: (options) ->
    @options = options || {}

  render: ->
    window.location.href = "/datasets"

