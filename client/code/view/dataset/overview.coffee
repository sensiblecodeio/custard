class Cu.View.DatasetOverview extends Backbone.View
  className: 'dataset-overview'
  
  render: ->
    detailsView = new Cu.View.DatasetDetails model: @model
    @$el.append detailsView.render().el
    viewsView = new Cu.View.DatasetViews model: @model
    @$el.append viewsView.render().el
    toolsView = new Cu.View.DatasetTools
      model: @model
      collection: @options.tools
    @$el.append toolsView.render().el
    @
