class Cu.View.TableXtract extends Backbone.View
  className: 'table-xtract'

  render: ->
    @el.innerHTML = JST['table-xtract']()
    @
