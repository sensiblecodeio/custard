class Cu.View.DatasetGroup extends Backbone.View
  className: 'dataset-group'

  render: ->
    @addDataset()
    @addViews()
    @

  addDataset: ->
    view = new Cu.View.DatasetTile model: @model
    @$el.html view.render().el

  addViews: =>
    @model.get('views').each @addView

  addView: (view) =>
    v = new Cu.View.ViewTile model: view
    @$el.append v.render().el
