class Cu.View.ToolListHeader extends Backbone.View
  className: 'container header'

  events:
    'click': (e) ->
      e.stopPropagation()
    'keyup .search-query': 'keyupPageSearch'

  initialize: (options) ->
    @options = options || {};
  
  render: ->
    if @options.type == 'importers'
      @$el.append('<h2>Create a new dataset&hellip;</h2>')
    else
      @$el.append('<h2>What would you like to do?</h2>')
    @$el.append("""<div class="btn-toolbar">
      <div class="btn-group">
        <input type="text" class="input-medium search-query">
      </div>
    </div>""")
    @

  keyupPageSearch: (e) ->
    $input = $(e.target)
    if e.keyCode is 27
      $('#chooser .tool').show()
      $input.val('').blur()
    else
      t = $input.val()
      if t != ''
        $('#chooser .tool').each ->
          if $(this).text().toUpperCase().indexOf(t.toUpperCase()) >= 0
            $(this).show()
          else
            $(this).hide()
      else if t == ''
        $('#chooser .tool').show()