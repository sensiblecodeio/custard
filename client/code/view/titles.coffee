class Cu.View.Title extends Backbone.View
  tagName: 'h2'

  initialize: ->
    @setDocumentTitle()

  render: ->
    @$el.html """#{@options.text}"""
    @

  setDocumentTitle: (model) =>
    if model?
      t = "#{model.get 'displayName'} | "
    else if @options.text
      t = "#{@options.text} | "
    else
      t = ''
    window.document.title = """#{t}ScraperWiki"""

class Cu.View.DataSetTitle extends Cu.View.Title
  tagName: 'h2'
  events:
    'click .editable': 'nameClicked'
    'blur input': 'editableNameBlurred'
    'keypress input': 'keypressOnEditableName'

  initialize: ->
    @model.on 'change', @setDocumentTitle, @
    @setDocumentTitle(@model)

  render: ->
    tpl = """
      <a href="/">My Datasets</a>
      <span class="slash">/</span>
      <span class="editable">#{@model.get 'displayName'}</span>
      <input type="text" id="txtName" style="display: none"/>
    """
    @$el.html tpl
    @

  nameClicked: (e) ->
    e.preventDefault()
    $a = @$el.find('.editable')
    $a.hide()
    @$el.find('input').val(@model.name()).css('width', $a.width() + 20).show 0, ->
      @focus()

  editableNameBlurred: ->
    $label = @$el.find('.editable')
    $input = @$el.find('input')
    @newName = $.trim($input.val())
    if @newName == '' or @newName == $label.text()
      $label.show().next().hide();
    else
      $input.hide()
      $label.text(@newName).show()
      @model.save displayName: @newName,
        success: =>
          $label.addClass 'saved'
          setTimeout ->
            $label.removeClass 'saved'
          , 1000
        error: (e) =>
          $label.text @model.name()
          console.log 'error saving new name', e

  editableNameEscaped: (e) ->
    e.preventDefault()
    @$el.find('.editable').show().next().hide()

  keypressOnEditableName: (event) ->
    @editableNameBlurred() if event.keyCode is 13
    @editableNameEscaped() if event.keyCode is 27
