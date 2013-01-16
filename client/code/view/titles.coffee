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

class Cu.View.ToolTitle extends Cu.View.Title
  render: ->
    dataset = @options.dataset
    tool = @options.tool

    tpl = """
      <a href="/">My Datasets</a>
      <span class="slash">/</span>
      <a href="/dataset/#{dataset.id}">#{dataset.get 'displayName'}</a>
      <span class="slash">/</span>
      <span>#{tool.get 'displayName'}</span>
    """
    @$el.html tpl
    @

class Cu.View.DataSetTitle extends Cu.View.Title
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
    @$el.find('input').val(@model.name()).css('width', $a.width() + 20).show 0, ->
      @focus()
    $a.hide()

  editableNameBlurred: ->
    $label = @$el.find('.editable')
    $input = @$el.find('input')
    @newName = $.trim($input.val())
    if @newName == '' or @newName == $label.text()
      $label.show().next().hide()
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
          console.warn 'error saving new name', e

  editableNameEscaped: (e) ->
    e.preventDefault()
    @$el.find('.editable').show().next().hide()

  keypressOnEditableName: (event) ->
    @editableNameBlurred() if event.keyCode is 13
    @editableNameEscaped() if event.keyCode is 27

# :TODO: This should be refactored into/with Cu.View.DataSetTitle
class Cu.View.ViewTitle extends Cu.View.Title
  events:
    'click .editable': 'nameClicked'
    'blur input': 'editableNameBlurred'
    'keypress input': 'keypressOnEditableName'

  dataset: -> @model.get('plugsInTo')

  initialize: ->
    @model.on 'change', @setDocumentTitle, @
    @setDocumentTitle(@model)

  render: ->
    tpl = """
      <a href="/">My Datasets</a>
      <span class="slash">/</span>
      <a href="/dataset/#{@dataset().get 'box'}/">#{@dataset().get 'displayName'}</a>
      <span class="slash">/</span>
      <span class="editable">#{@model.get 'displayName'}</span>
      <input type="text" id="txtName" style="display: none"/>
    """
    @$el.html tpl
    @

  nameClicked: (e) ->
    e.preventDefault()
    $a = @$el.find('.editable')
    @$el.find('input').val(@model.get 'displayName').css('width', $a.width() + 20).show 0, ->
      @focus()
    $a.hide()

  editableNameBlurred: ->
    $label = @$el.find('.editable')
    $input = @$el.find('input')
    @newName = $.trim($input.val())
    @oldName = $label.text()
    if @newName == '' or @newName == $label.text()
      $label.show().next().hide()
    else
      $input.hide()
      $label.text(@newName).show()
      @model.set 'displayName', @newName
      @dataset().save {},
        success: =>
          $label.addClass 'saved'
          setTimeout ->
            $label.removeClass 'saved'
          , 1000
        error: (e) =>
          $label.text @oldName
          @model.set 'displayName', @oldName
          console.warn 'error saving new name', e

  editableNameEscaped: (e) ->
    e.preventDefault()
    @$el.find('.editable').show().next().hide()

  keypressOnEditableName: (event) ->
    @editableNameBlurred() if event.keyCode is 13
    @editableNameEscaped() if event.keyCode is 27
