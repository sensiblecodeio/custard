window.AdminHeaderView = class AdminHeaderView extends Backbone.View
  el: '#header'

  initialize: ->
    @render()

  render: ->
    @$el.empty()
    @$el.load '/tpl/admin_header', =>
      topAndTailDropdowns()
    
