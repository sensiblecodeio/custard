class Cu.View.DataSetViews extends Backbone.View
  className: 'dataset-views'

  render: ->
    @$el.append '<h4>Views on this data:</h4>'
    @addViews()
    @

  addViews: =>
    console.log @model
    @model.get('views').each @addView

  addView: (view) =>
    v = new Cu.View.ViewTile model: view
    @$el.append v.render().el
