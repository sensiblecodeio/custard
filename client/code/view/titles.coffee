class Cu.View.Title extends Backbone.View
  tagName: 'h2'

  initialize: ->
    @setDocumentTitle()

  render: ->
    tpl = """#{@options.text}"""
    if window.user.effective?.logoUrl?
      tpl = """<img src="#{window.user.effective.logoUrl}"> #{tpl}"""
    @$el.html tpl
    @

  setDocumentTitle: (model) =>
    if model?
      t = "#{model.get 'displayName'} | "
    else if @options.text
      t = "#{@options.text} | "
    else
      t = ''
    window.document.title = """#{t}ScraperWiki"""

class Cu.View.EditableTitle extends Cu.View.Title
  initialize: ->
    @model.on 'change', @setDocumentTitle, @
    @setDocumentTitle(@model)
    # set this so we can override it in Cu.View.ViewTitle
    # (where the model to save is in fact the parent dataset's model)
    @modelToSave = @model

  nameClicked: (e) ->
    e.preventDefault()
    $a = @$el.find('.editable')
    @$el.find('input')
      .val(@model.get 'displayName')
      .css('width', $a.width() + 20)
      .show 0, ->
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
      @modelToSave.save {},
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


class Cu.View.DatasetSettingsTitle extends Cu.View.Title
  render: ->
    tpl = """
      <a href="/">My Datasets</a>
      <span class="slash">/</span>
      <a href="/dataset/#{@model.get 'box'}/">#{@model.get 'displayName'}</a>
      <span class="slash">/</span>
      Settings
    """
    if window.user.effective?.logoUrl?
      tpl = """<img src="#{window.user.effective.logoUrl}"> #{tpl}"""
    @$el.html tpl
    @


class Cu.View.DatasetTitle extends Cu.View.EditableTitle
  #TODO: create BaseView to extend events, for the DRY
  events:
    'click .editable': 'nameClicked'
    'blur input': 'editableNameBlurred'
    'keypress input': 'keypressOnEditableName'

  render: ->
    tpl = """
      <a href="/">My Datasets</a>
      <span class="slash">/</span>
      <span class="editable">#{@model.get 'displayName'}</span>
      <input type="text" id="txtName" style="display: none"/>
    """
    if window.user.effective?.logoUrl?
      tpl = """<img src="#{window.user.effective.logoUrl}"> #{tpl}"""
    @$el.html tpl
    @

class Cu.View.ViewTitle extends Cu.View.EditableTitle
  events:
    'click .editable': 'nameClicked'
    'blur input': 'editableNameBlurred'
    'keypress input': 'keypressOnEditableName'

  initialize: ->
    super()
    @modelToSave = @model.get 'plugsInTo'

  render: ->
    tpl = """
      <a href="/">My Datasets</a>
      <span class="slash">/</span>
      <a href="/dataset/#{@modelToSave.get 'box'}/">#{@modelToSave.get 'displayName'}</a>
      <span class="slash">/</span>
      <span class="editable">#{@model.get 'displayName'}</span>
      <input type="text" id="txtName" style="display: none"/>
    """
    if window.user.effective?.logoUrl?
      tpl = """<img src="#{window.user.effective.logoUrl}"> #{tpl}"""
    @$el.html tpl
    @
