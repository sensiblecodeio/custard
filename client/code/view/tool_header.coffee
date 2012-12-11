class Cu.View.ToolHeader extends Backbone.View
  el: '#header'

  initialize: ->
    @render()

  render: ->
    @$el.load '/tpl/tool_header', =>
      u = window.user
      @$el.find('h2 a').text @model.get 'name'
      @$el.find('h1').append '<i class="icon-chevron-left"></i>'

   # Rename spike
   logoClicked: (event) ->
     event.preventDefault()
     window.app.navigate "/", {trigger: true}
   
