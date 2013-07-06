class Cu.View.About extends Backbone.View
  className: "about"
  events:
    'click .showMore': 'showMore'

  render: ->
    @el.innerHTML = JST['about']()
    $('.more', @$el).hide().before('<span class="showMore">&hellip; <i>More&nbsp;&raquo;</i></span>')
    @

  showMore: (e) ->
    $moreLink = $(e.currentTarget)
    $moreLink.hide().next().show()