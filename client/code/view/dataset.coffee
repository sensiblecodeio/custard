class Cu.View.DataSet extends Backbone.View
  className: 'dataset'

  initialize: ->
    @model.on 'change', @render, this

  render: ->
    @$el.html JST['dataset']
      dataset: @model.toJSON()
      user: window.user.effective
    @
