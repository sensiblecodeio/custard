class Cu.View.Subnav extends Backbone.View
  className: 'subnav-wrapper'

  render: ->
    @$el.html("""
      <div class="btn-toolbar" id="subnav-path">
        <h1 class="btn-group">
          <a class="btn btn-link" href="#{@options.url or window.location.href}">#{@options.text}</a>
        </h1>
      </div>
      <hr>""")
    @

  # THIS IS NOT USED
  # TODO: actually inherit >:/
  setDocumentTitle: (model) =>
    if model?
      t = "#{model.get 'displayName'} | "
    else if @options.text
      t = "#{@options.text} | "
    else
      t = ''
    window.document.title = """#{t}ScraperWiki"""


class Cu.View.DataHubNav extends Backbone.View
  className: 'subnav-wrapper'

  events:
    'click .context-switch li': 'liClick'
    'click .new-dataset': 'showChooser'
    'focus .context-switch input': 'focusContextSearch'
    'keyup .context-switch input': 'keyupContextSearch'
    'mouseenter .context-search-result': 'hoverContextSearchResult'
    'keyup #subnav-options .search-query': 'keyupPageSearch'

  render: ->
    h1 = """<h1 class="btn-group context-switch">
        <a class="btn btn-link dropdown-toggle" data-toggle="dropdown">
          <img src="#{window.user.effective.logoUrl or window.user.effective.avatarUrl}" />#{window.user.effective.displayName or window.user.effective.shortName}&rsquo;s data hub<span class="caret"></span>
        </a>
        <ul id="user-contexts" class="dropdown-menu">
        </ul>
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

    @displayContexts()

    # close the tool chooser if it's open
    # (ie: if we've just used the back button to close it)
    if $('#chooser').length
      $('#chooser').fadeOut 200, ->
        $(this).remove()
      $(window).off('keyup')
    @

  displayContexts: ->
    $userContexts = $('#user-contexts').empty()
    return if $userContexts.is(':visible')

    users = Cu.CollectionManager.get Cu.Collection.User
    users.fetch
      success: =>
        if users.length <= 1
          $('.context-switch > a').attr('data-toggle', null)
           .removeClass('dropdown-toggle', null)
           .css('cursor', 'default')
           .children('span').remove()
        users.each @appendContextUser

  appendContextUser: (user) ->
    $userContexts = $('#user-contexts')
    $userContexts.append """<li class="context-search-result">
      <a href="/switch/#{user.get 'shortName'}/" data-nonpushstate>
        <img src="#{user.get('logoUrl') or user.get('avatarUrl') or '/image/avatar.png'}" alt="#{user.get 'shortName'}" />
        #{user.get 'displayName' or user.get 'shortName'}
      </a>
    </li>"""

  liClick: (e) ->
    # stops the dropdown menu disappearing when you click inside it
    e.stopPropagation()

  showChooser: ->
    app.navigate "/chooser", trigger: true

  # TODO: should use user collection
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
    if e.which == 40
      e.preventDefault()
      @highlightNextResult()
    else if e.which == 38
      e.preventDefault()
      @highlightPreviousResult()
    else if e.which == 13
      e.preventDefault()
      @activateHighlightedResult()
    else
      @refreshContextResults()

  refreshContextResults: ->
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
        if runnersup.length + tophits.length > 0
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
          # No users match the search term!
          li.after """<li class="context-search-result no-matches">No results for &ldquo;#{t}&rdquo;</li>"""
      else
        # Oops! window.users isn't ready yet. Show loading spinner.
        # (It'll be hidden by the ajax success call in @focusContextSearch())
        $('.context-switch input').addClass 'loading'
    else if t == ''
      results.remove()

  highlightNextResult: ->
    $selected = $('.context-search-result.selected')
    if $selected.length
      if $selected.next('.context-search-result').length
        $selected.removeClass('selected').next('.context-search-result').addClass('selected')
    else
      $('.context-search-result').first().addClass('selected')

  highlightPreviousResult: ->
    $selected = $('.context-search-result.selected')
    if $selected.length
      if $selected.prev('.context-search-result').length
        $selected.removeClass('selected').prev('.context-search-result').addClass('selected')
    else
      $('.context-search-result').last().addClass('selected')

  activateHighlightedResult: ->
    $results = $('.context-search-result')
    $selected = $('.context-search-result.selected')
    if $selected.length
      window.location = $('a', $selected).attr('href')
    else if $results.length == 1
      $first = $results.first().addClass('selected')
      window.location = $('a', $first).attr('href')
    else
      @highlightNextResult()

  hoverContextSearchResult: ->
    $('.context-search-result.selected').removeClass('selected')

  keyupPageSearch: (e) ->
    $input = $(e.target)
    if e.keyCode is 27
      $('.dataset.tile').show()
      $input.val('').blur()
    else
      t = $input.val()
      if t != ''
        $('.dataset.tile').each ->
          if $(this).children('h3').text().toUpperCase().indexOf(t.toUpperCase()) >= 0
            $(this).show()
          else
            $(this).hide()
      else if t == ''
        $('.dataset.tile').show()


# Toolbar contains a dataset's name, and all the tools acting on it
class Cu.View.Toolbar extends Backbone.View
  id: 'toolbar'
  className: 'subnav-wrapper'

  events:
    'click .new-view': 'showChooser'
    'click .hide-dataset': 'hideDataset'
    'click .rename-dataset': 'renameDataset'
    'click .dropdown-toggle': 'showDropdownMenuCloser'
    'click #dropdown-menu-closer': 'hideDropdownMenuCloser'
    'blur #editable-input input': 'editableNameBlurred'
    'keyup #editable-input input': 'keypressOnEditableName'
  
  initialize: ->
    @toolsView = new Cu.View.DatasetTools
      model: @model
      view: @options.view

  render: ->
    @$el.html """<div id="dropdown-menu-closer"></div>
    <div id="dataset-meta">
      <h3>#{@model.get 'displayName'}</h3> 
      <span class="input-append" id="editable-input">
        <input type="text" value="#{@model.get 'displayName'}">
        <button class="btn">Save</button>
      </span>
      <div class="actions">
        <a class="dropdown-toggle" data-toggle="dropdown">Options</a>
        <ul class="dropdown-menu pull-right">
          <li><a class="rename-dataset"><img src="/image/icon-rename.png" width="16" height="16" /> Rename</a></li>
          <li><a class="hide-dataset"><img src="/image/icon-cross.png" width="16" height="16" /> Delete</a></li>
        </ul>
      </div>
    </div>"""
    @$el.append(@toolsView.render().el)
    @

  showChooser: ->
    app.navigate "/dataset/#{@model.get 'box'}/chooser", trigger: true

  hideDataset: ->
    @model.save {state: 'deleted'},
      success: (model, response, options) =>
        window.app.navigate "/", {trigger: true}
      error: (model, xhr, options) =>
        alert('Sorry, your dataset could not be hidden')
        console.warn 'Dataset could not be hidden!', model, xhr, options

  renameDataset: ->
    $('#editable-input', @$el).css('display', 'table-cell').prev().hide()
    $('#editable-input input', @$el).focus()

  showDropdownMenuCloser: ->
    # Clicks on tool iframes can't close open dropdowns inside of #toolbar.
    # So, we show a big transparent mask div, which will absorb the clicks.
    $('#dropdown-menu-closer').show()

  hideDropdownMenuCloser: ->
    # If the user closes the dropdown via normal means, the mask div
    # will be left in place. This removes it when they click it.
    $('#dropdown-menu-closer').hide()

  editableNameBlurred: (e) ->
    $label = $('#dataset-meta h3')
    $wrapper = $label.next()
    $input = $wrapper.children('input')
    @newName = $.trim($input.val())
    @oldName = $label.text()
    if @newName == '' or @newName == $label.text()
      @editableNameEscaped(e)
    else
      $wrapper.hide()
      $label.text(@newName).show()
      @model.set 'displayName', @newName
      @model.save {},
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
    $('#editable-input input', @$el).val(@model.get "displayName").parent().hide().prev().show()

  keypressOnEditableName: (e) ->
    @editableNameBlurred(e) if e.keyCode is 13
    @editableNameEscaped(e) if e.keyCode is 27


class Cu.View.SignUpNav extends Backbone.View
  className: 'subnav-wrapper'

  render: ->
    # Assumes @options.plan is set
    plan = @options.plan
    plan = plan.toUpperCase()[0] + plan.toLowerCase()[1..]

    @$el.html("""
      <div class="btn-toolbar" id="subnav-path">
        <h1 class="btn-group">
          <a class="btn btn-link" href="/">Sign Up</a>
        </h1>
        <div class="btn-group">
          <span class="slash">/</span>
        </div>
        <h1 class="btn-group" style="margin-left: 7px">
          <a class="btn btn-link" href="#{window.location.href}">#{plan}</a>
        </h1>
      </div>
      <hr>""")
    @


class Cu.View.HelpNav extends Backbone.View
  className: 'subnav-wrapper'

  render: ->
    switch @options.section
      when 'corporate'
        name = 'Corporate FAQs'
      when 'developer'
        name = 'Developer Docs'
      when 'zig'
        name = 'ZIG'
      when 'twitter-search'
        name = 'Scrape Tweets and download as a spreadsheet'
      when 'upload-and-summarise'
        name = 'Upload and summarise a spreadsheet of data'
      when 'code-in-your-browser'
        name = 'Code a scraper in your browser'
      when 'make-your-own-tool'
        name = 'Make your own tool with HTML, JavaScript & Python'
      when 'whats-new'
        name = 'What’s new?'

    html = """
      <div class="btn-toolbar" id="subnav-path">
        <h1 class="btn-group">
          <a class="btn btn-link" href="/help">Help</a>
        </h1>"""

    if name
      html += """<div class="btn-group">
          <span class="slash">/</span>
        </div>
        <h1 class="btn-group" style="margin-left: 7px">
          <a class="btn btn-link">#{name}</a>
        </h1>"""

    html += "</div><hr>"

    @$el.html html
    @


class Cu.View.ToolShopNav extends Backbone.View
  className: 'subnav-wrapper'

  render: ->
    @$el.html("""
      <div class="btn-toolbar" id="subnav-path">
        <h1 class="btn-group">
          <a class="btn btn-link" href="/tools">Tool Shop</a>
        </h1>
        <div class="btn-group">
          <span class="slash">/</span>
        </div>
        <h1 class="btn-group" style="margin-left: 7px">
          <a class="btn btn-link" href="#{@options.url}">#{@options.name}</a>
        </h1>
      </div>
      <hr>""")
    @
