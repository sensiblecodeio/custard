class Cu.View.HomeContent extends Backbone.View
  events:
    'click #tools .metro-tile': 'clickTool'

  render: ->
    @addTools()
    
  addDatasets: ->
    @collection.each @addDataset

  addDataset: (dataset) =>
    view = new Cu.View.DataSetGroup model: dataset
    @$el.append view.render().el

  clickTool: (event) ->
    # TODO: refactor into Tool view
    name = ($(event.target).closest('.metro-tile').attr 'class').split(' ')[1]
    window.app.navigate "tool/#{name}", {trigger: true}


