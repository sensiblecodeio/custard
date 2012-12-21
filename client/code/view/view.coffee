class Cu.View.View extends Backbone.View
  className: 'dataset'
  events:
    'click': 'click'

  render: ->
    @$el.html JST['dataset']
      dataset: @model.toJSON()
      user: window.user.effective
    @

  click: ->
    window.app.navigate "dataset/#{@model.id}", {trigger: true}
