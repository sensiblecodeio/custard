class Cu.View.DatasetTools extends Backbone.View
  className: 'dropdown-menu pull-right'
  tagName: 'ul'
  id: 'dataset-tools'

  initialize: ->
    @toolInstances = @model.get('views').visible()
    app.tools().on 'fetched', @addToolArchetypes, @

  render: ->
    @addToolInstance @model
    @toolInstances.each @addToolInstance
    @addToolArchetypes()
    @$el.append('<li><a class="new-view">More tools&hellip;</a></li>')
    @

  addToolArchetypes: ->
    app.tools().basics().each @addToolArchetype

  addToolArchetype: (toolModel) =>
    v = new Cu.View.PluginTile { model: toolModel, dataset: @model }
    @$el.append v.render().el

  addToolInstance: (instance) =>
    v = new Cu.View.ToolMenuItem model: instance
    @$el.append v.render().el
