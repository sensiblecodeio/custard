class Cu.View.ContextLink extends Backbone.View
  tagName: 'li'
  className: 'context'

  render: ->
    # @options should be an object containing
    # contextUser (object) and contextActive (bool)
    @$el.html JST.contextlink @options
    @