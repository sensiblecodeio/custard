class Cu.View.AdminHeader extends Backbone.View
  el: '#header'

  initialize: (title) ->
    @title = title
    @render()

  render: ->
    @$el.empty()
    @$el.load '/tpl/admin_header', =>
      @$el.find('h2 a').text(@title)
      topAndTailDropdowns()
    
