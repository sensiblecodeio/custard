class Cu.View.Title extends Backbone.View
  render: ->
    @$el.html """<h2>#{@options.text}</h2>"""
    @

class Cu.View.DataSetTitle extends Backbone.View
  events:
    'click a': 'nameClicked'
    'blur input': 'editableNameBlurred'
    'keypress input': 'enterOnEditableName'

  render: ->
    tpl = """
      <a href="#">#{@model.get 'displayName'}</a>
      <input type="text" id="txtName" style="display: none"/>
    """
    @$el.html tpl
    @

  nameClicked: (e) ->
    e.preventDefault()
    @$el.find('a').hide()
    @$el.find('input').val @model.name()
    @$el.find('input').show 0, ->
      @focus()
      @select()

  editableNameBlurred: ->
    label = @$el.find('a')
    if not label.is(':visible')
      label.show()
      @newName = (@$el.find('input').hide()).val()
      @$el.find('a').text @newName
      @model.save displayName: @newName,
        success: =>
        error: (e) =>
          @$el.find('a').text @model.name()
          console.log e


  enterOnEditableName: (event) ->
    @editableNameBlurred() if event.keyCode is 13
