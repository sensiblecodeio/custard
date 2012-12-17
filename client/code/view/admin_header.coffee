class Cu.View.AdminHeader extends Backbone.View
  el: '#header'

  initialize: ->
    @render()

  render: ->
    @$el.empty()
    @$el.load '/tpl/admin_header', =>
      @$el.find('h2 a').text @title
      topAndTailDropdowns()
    
