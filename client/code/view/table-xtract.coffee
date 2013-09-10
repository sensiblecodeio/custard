class Cu.View.TableXtract extends Backbone.View
  className: 'table-xtract'
  events:
    'click #hero a[href="#try-it-out"]': (e) ->
      e.preventDefault()
      $('html, body').animate
        scrollTop: $('#try-it-out').offset().top - 40
      , 250, ->
        $('#try-it-out input').focus()

  render: ->
    @el.innerHTML = JST['table-xtract']()
    @
