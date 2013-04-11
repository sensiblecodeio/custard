class Cu.View.DatasetViews extends Backbone.View
  className: 'dataset-views'

  initialize: ->
    @views = @model.get('views').visible()
    app.tools().on 'sync', @addTools, @

  render: ->
    console.log @views
    if @views.length > 0
      @views.each @addView
    else
      @addTools() if app.tools().length
    return this

  addTools: ->
    console.log 'add tools'
    if @views.length <= 0
      app.tools().basics().each @addTool

  addTool: (tool) =>
    v = new Cu.View.PluginTile { model: tool, dataset: @model }
    @$el.append v.render().el

  addView: (view) =>
    v = new Cu.View.ViewTile model: view
    @$el.append v.render().el
