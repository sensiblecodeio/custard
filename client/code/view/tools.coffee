class Cu.View.ToolList extends Backbone.View
  className: 'my-tools'
    
  events:
    'click .tool': 'clickTool'

  render: ->
    @addTools()
    @

  addTools: ->
    @collection.each @addTool

  addTool: (tool) =>
    @$el.append JST['tool'](tool.toJSON())

  clickTool: (e) ->
    e.preventDefault()
    url = $(e.target).closest('.tool').find('h3 a').attr('href')
    window.app.navigate url, {trigger: true}
