class Cu.View.DataSetOverview extends Backbone.View
  className: 'dataset-overview'
  
  render: ->
    detailsView = new Cu.View.DataSetDetails model: @model
    @$el.append detailsView.render().el
    viewsView = new Cu.View.DataSetViews model: @model
    @$el.append viewsView.render().el
    toolsView = new Cu.View.DataSetTools
      model: @model
      collection: @options.tools
    @$el.append toolsView.render().el
    @
