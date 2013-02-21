class Cu.View.Subnav extends Backbone.View
  render: ->
    @$el.html("""
      <div class="btn-toolbar" id="subnav-path">
        <h1 class="btn-group">
          <a class="btn btn-link" href="#{@options.url or window.location.href}">#{@options.text}</a>
        </h1>
      </div>""")
    @


class Cu.View.DataHubNav extends Backbone.View
  events:
    'click .context-switch li': 'liClick'
    'click .new-dataset': 'showChooser'
    'focus .context-switch input': 'focusContextSearch'
    'keyup .context-switch input': 'keyupContextSearch'

  render: ->
    if window.user.real.isStaff?
      h1 = """<h1 class="btn-group context-switch">
          <a class="btn btn-link dropdown-toggle" data-toggle="dropdown">
            <img src="#{window.user.effective.logoUrl or window.user.effective.avatarUrl}" />#{window.user.effective.displayName or window.user.effective.shortName}&rsquo;s data hub<span class="caret"></span>
          </a>
          <ul class="dropdown-menu">
            <li class="search"><input type="search" placeholder="Switch profile&hellip;"></li>
            <!--<li><a href="#">Another action</a></li>-->
          </ul>
        </h1>"""
    else
      h1 = """<h1 class="btn-group">
          <a class="btn btn-link">
            <img src="#{window.user.effective.logoUrl or window.user.effective.avatarUrl}" />#{window.user.effective.displayName or window.user.effective.shortName}&rsquo;s data hub
          </a>
        </h1>"""

    @$el.html("""
      <div class="btn-toolbar" id="subnav-path">#{h1}</div>
      <div class="btn-toolbar" id="subnav-options">
        <div class="btn-group">
          <a class="btn new-dataset"><i class="icon-plus"></i> New Dataset</a>
        </div>
        <div class="btn-group">
          <input type="text" class="input-medium search-query">
        </div>
      </div>""")
    @

  liClick: (e) ->
    # stops the dropdown menu disappearing when you click inside it
    e.stopPropagation()

  showChooser: ->
    # :TODO: We shouldn't be fetching tools in here.
    if window.tools.length == 0
      window.tools.fetch
        success: ->
          t = new Cu.View.ToolList {collection: window.tools}
          $('body').append t.render().el
        error: (x,y,z) ->
          console.warn 'ERRROR', x, y, z
    else
      t = new Cu.View.ToolList {collection: window.tools}
      $('body').append t.render().el

  focusContextSearch: ->
    $.ajax
      url: '/api/user/'
      dataType: 'json'
      success: (latestUsers) ->
        window.users = for user in latestUsers
          user
        if $('.context-switch input').is('.loading')
          $('.context-switch input').removeClass('loading').trigger 'keyup'
      error: (jqXHR, textStatus, errorThrown) ->
        $('.context-switch input').removeClass 'loading'
        console.warn 'Could not query users API', errorThrown

  keyupContextSearch: (e) ->
    li = $('.context-switch li.search')
    input = li.children('input')
    t = input.val()
    results = $('.context-search-result')
    if t != ''
      results.remove()
      tophits = []
      runnersup = []
      if window.users?
        for user in window.users
          if user.shortName == window.user.effective.shortName
            continue
          m1 = if user.displayName? then user.displayName.toLowerCase().search(t.toLowerCase()) else -1
          m2 = if user.shortName? then user.shortName.toLowerCase().search(t.toLowerCase()) else -1
          if m1 == 0 or m2 == 0
            tophits.push user
          else if m1 > 0 or m2 > 0
            runnersup.push user
        for runnerup in runnersup
          li.after """<li class="context-search-result">
            <a href="/switch/#{runnerup.shortName}/" data-nonpushstate>
              <img src="#{runnerup.logoUrl or runnerup.avatarUrl or '/image/avatar.png'}" alt="#{runnerup.shortName}" />
              #{runnerup.displayName or runnerup.shortName}
            </a>
          </li>"""
        for tophit in tophits
          li.after """<li class="context-search-result">
            <a href="/switch/#{tophit.shortName}/" data-nonpushstate>
              <img src="#{tophit.logoUrl or tophit.avatarUrl or '/image/avatar.png'}" alt="#{tophit.shortName}" />
              #{tophit.displayName or tophit.shortName}
            </a>
          </li>"""
      else
        # Oops! window.users isn't ready yet. Show loading spinner.
        # (It'll be hidden by the ajax success call in @focusContextSearch())
        $('.context-switch input').addClass 'loading'
    else if t == ''
      results.remove()


class Cu.View.EditableSubnav extends Backbone.View
  initialize: ->
    @model.on 'change', @setDocumentTitle, @
    # set this so we can override it in Cu.View.ViewSubnav
    # (where the model to save is in fact the parent dataset's model)
    @modelToSave = @model

  nameClicked: (e) ->
    e.preventDefault()
    $a = @$el.find('.editable')
    $a.next()
      .val(@model.get 'displayName')
      .css('width', $a.width() + 20)
      .show 0, ->
        @focus()
    $a.hide()

  editableNameBlurred: ->
    $label = @$el.find('.editable')
    $input = $label.next()
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
          $label.text(@oldName).addClass 'error'
          setTimeout ->
            $label.removeClass 'error'
          , 1000
          @model.set 'displayName', @oldName
          console.warn 'error saving new name', e

  editableNameEscaped: (e) ->
    e.preventDefault()
    @$el.find('.editable').show().next().hide()

  keypressOnEditableName: (event) ->
    @editableNameBlurred() if event.keyCode is 13
    @editableNameEscaped() if event.keyCode is 27


class Cu.View.DatasetNav extends Cu.View.EditableSubnav
  #TODO: create BaseView to extend events, for the DRY
  events:
    'click .editable': 'nameClicked'
    'blur #editable-input': 'editableNameBlurred'
    'keypress #editable-input': 'keypressOnEditableName'

  render: ->
    @$el.html("""
      <div class="btn-toolbar" id="subnav-path">
        <h1 class="btn-group">
          <a class="btn btn-link">
            <img src="#{window.user.effective.logoUrl or window.user.effective.avatarUrl}" />#{window.user.effective.displayName or window.user.effective.shortName}&rsquo;s data hub</span>
          </a>
        </h1>
        <div class="btn-group">
          <span class="slash">/</span>
        </div>
        <div class="btn-group">
          <span class="btn btn-link editable">#{@model.get 'displayName'}</span>
          <input type="text" id="editable-input" style="display: none"/>
        </div>
      </div>""")
    @

class Cu.View.DatasetSettingsNav extends Backbone.View
  # This view should be passed a dataset model!
  render: ->
    @$el.html("""
      <div class="btn-toolbar" id="subnav-path">
        <h1 class="btn-group">
          <a class="btn btn-link">
            <img src="#{window.user.effective.logoUrl or window.user.effective.avatarUrl}" />#{window.user.effective.displayName or window.user.effective.shortName}&rsquo;s data hub</span>
          </a>
        </h1>
        <div class="btn-group">
          <span class="slash">/</span>
        </div>
        <div class="btn-group">
          <a class="btn btn-link" href="/dataset/#{@model.get 'box'}">#{@model.get 'displayName'}</a>
        </div>
        <div class="btn-group">
          <span class="slash">/</span>
        </div>
        <div class="btn-group">
          <span class="btn btn-link">Settings</span>
        </div>
      </div>""")
    @

class Cu.View.ViewNav extends Cu.View.EditableSubnav
  #TODO: create BaseView to extend events, for the DRY
  events:
    'click .editable': 'nameClicked'
    'blur #editable-input': 'editableNameBlurred'
    'keypress #editable-input': 'keypressOnEditableName'

  render: ->
    @$el.html("""
      <div class="btn-toolbar" id="subnav-path">
        <h1 class="btn-group">
          <a class="btn btn-link">
            <img src="#{window.user.effective.logoUrl or window.user.effective.avatarUrl}" />#{window.user.effective.displayName or window.user.effective.shortName}&rsquo;s data hub</span>
          </a>
        </h1>
        <div class="btn-group">
          <span class="slash">/</span>
        </div>
        <div class="btn-group">
          <a class="btn btn-link" href="/dataset/#{@model.get('plugsInTo').get 'box'}">#{@model.get('plugsInTo').get 'displayName'}</a>
        </div>
        <div class="btn-group">
          <span class="slash">/</span>
        </div>
        <div class="btn-group">
          <span class="btn btn-link editable">#{@model.get 'displayName'}</span>
          <input type="text" id="editable-input" style="display: none"/>
        </div>
      </div>""")
    @