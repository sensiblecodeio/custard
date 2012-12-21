class Cu.View.DataSetViews extends Backbone.View
  className: 'dataset-views'
  events:
    'click': 'click'

  render: ->
    # Cheating
    @$el.append JST['dataset-views']()
    @

  click: (e) ->
    # TODO: make this suck less
    name = ($(e.target).closest('.view').attr 'class').split(' ')[1]
    window.app.navigate "/dataset/#{@model.id}/#{name}", {trigger: true}
