class Cu.View.DataSet extends Backbone.View
  className: 'dataset'
  events:
    'click': 'click'

  render: ->
    @$el.html JST['dataset']
      dataset: @model.toJSON()
      user: window.user.effective
    @

  click: (e) ->
    e.preventDefault()
    window.app.navigate "dataset/#{@model.id}", {trigger: true}
