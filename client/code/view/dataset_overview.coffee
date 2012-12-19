class Cu.View.DataSetOverview extends Backbone.View
  className: 'dataset-overview'
  
  render: ->
    detailsView = new Cu.View.DataSetDetails model: @model
    @$el.append detailsView.render().el
    viewsView = new Cu.View.DataSetViews
    @$el.append viewsView.render().el
    @
