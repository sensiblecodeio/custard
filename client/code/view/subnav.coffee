class Cu.View.Subnav extends Backbone.View
  className: 'subnav-wrapper'

  initialize: (options) ->
    @options = options || {};

  render: ->
    window.document.title = @options.title or 'ScraperWiki'
    @$el.html JST['subnav'] @options
    @


class Cu.View.DataHubNav extends Backbone.View
  className: 'subnav-wrapper'

  events:
    'click .new-dataset': 'showChooser'
    'keyup #subnav-options .search-query': 'keyupPageSearch'
    'click #tile-view': 'showTileView'
    'click #list-view': 'showListView'

  initialize: (options) ->
    @options = options || {};

  render: ->
    name = window.user.effective.displayName or window.user.effective.shortName
    window.document.title = "#{name}’s data hub | ScraperWiki"
    @$el.html JST['subnav-home']
      avatar: window.user.effective.logoUrl or window.user.effective.avatarUrl
      name: name

    if window.user.effective.datasetDisplay == 'list'
      @$el.find('#list-view').addClass('active')
    else
      @$el.find('#tile-view').addClass('active')

    # close the tool chooser if it's open
    # (ie: if we've just used the back button to close it)
    if $('#chooser').length
      $('#chooser').fadeOut 200, ->
        $(this).remove()
      $(window).off('keyup')
    @

  showListView: ->
    @_updateUser {datasetDisplay: 'list'}, =>
      window.user.effective.datasetDisplay = 'list'
      window.app.appView.currentView.renderAsList()
      @$el.find('#list-view').addClass('active').siblings().removeClass('active')

  showTileView: ->
    @_updateUser {datasetDisplay: 'tiles'}, =>
      window.user.effective.datasetDisplay = 'tiles'
      window.app.appView.currentView.renderAsTiles()
      @$el.find('#tile-view').addClass('active').siblings().removeClass('active')

  _updateUser: (attributes, callback) ->
    user = new Cu.Model.User window.user.effective
    user.save attributes,
      type: 'put' # force backbone to issue a PUT, even though it thinks this is a new model
      success: callback

  showChooser: ->
    app.navigate "/chooser", trigger: true

  keyupPageSearch: (e) ->
    $input = $(e.target)
    if e.keyCode is 27
      $('.dataset-list .dataset').show()
      $input.val('').blur()
    else
      t = $input.val()
      if t != ''
        $('.dataset-list .dataset').each ->
          if $(this).children('h3, h4, td').text().toUpperCase().indexOf(t.toUpperCase()) >= 0
            $(this).show()
          else
            $(this).hide()
      else if t == ''
        $('.dataset-list .dataset').show()


# Toolbar contains a dataset's name, and all the tools acting on it
class Cu.View.Toolbar extends Backbone.View
  id: 'toolbar'
  className: 'subnav-wrapper'

  events:
    'click .new-view': 'showChooser'
    'click .hide-dataset': 'hideDataset'
    'click .rename-dataset': 'renameDataset'
    'click .hide-tool': 'hideTool'
    'click .git-ssh': 'gitSshTool'
    'click .api-endpoints': 'showApiEndpoints'
    'click .dropdown-toggle': 'showDropdownMenuCloser'
    'click #dropdown-menu-closer': 'hideDropdownMenuCloser'
    'blur #editable-input input': 'editableNameBlurred'
    'keyup #editable-input input': 'keypressOnEditableName'

  initialize: (options) ->
    @options = options || {};
    window.document.title = "#{@model.get 'displayName'} | ScraperWiki"
    @toolsView = new Cu.View.DatasetTools
      model: @model
      view: @options.view
    @model.on 'change:displayName', @renderName, this

  render: ->
    if app.tools().length
      @renderToolbar()
    else
      app.tools().fetch().done =>
        setTimeout =>
          @renderToolbar()
        , 1
    @

  renderToolbar: ->
    @$el.html JST['subnav-toolbar']
      displayName: @model.get 'displayName'
      color: @model.get('tool')?.get('manifest')?.color
      creatorDisplayName: @model.get 'creatorDisplayName'
    @$el.append @toolsView.render().el
    @$el.on 'mousewheel', (e, delta, deltaX, deltaY) ->
      e.preventDefault()
      $('#tool-options-menu, #dropdown-menu-closer', @$el).hide()
      $('#dataset-tools', @$el)[0].scrollLeft -= delta * 5
      window.app.subnavView.currentView.toolsView.showOrHideScroller()

  renderName: ->
    name = @model.get 'displayName'
    window.document.title = "#{name} | ScraperWiki"
    @$el.find('#dataset-meta h3').text name
    @$el.find('#dataset-meta input').val name

  showChooser: ->
    app.navigate "/dataset/#{@model.get 'box'}/chooser", trigger: true

  hideDataset: ->
    @model.destroy
      success: (model, response, options) =>
        window.app.navigate "/datasets", {trigger: true}
        setTimeout ->
          view = new Cu.View.DatasetTile {model: model}
          $('.new-dataset-tile').after view.render().el
        , 500

  renameDataset: ->
    w = $('#dataset-meta h3').width() + 100
    $('#editable-input', @$el).css('display', 'table-cell').prev().hide()
    $('#editable-input input', @$el).css('width', w).focus()

  hideTool: (e) ->
    e.stopPropagation()
    if window.selectedTool instanceof Cu.Model.View
      dataset = window.selectedTool.get('plugsInTo')
      window.selectedTool.set 'state', 'deleted'
      dataset.save {},
        success: ->
          window.location = "/dataset/#{dataset.get 'box'}/"

  gitSshTool: (e) ->
      e.stopPropagation()
      showSSHModal window.selectedTool, 'tool'

  showApiEndpoints: (e) ->
      e.stopPropagation()
      showAPIModal window.selectedTool


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
    $wrapper = $('#dataset-meta #editable-input')
    $input = $wrapper.children('input')
    @newName = $.trim($input.val())
    @oldName = $label.text()
    if @newName == '' or @newName == $label.text()
      @editableNameEscaped(e)
    else
      $wrapper.hide()
      $label.text(@newName).parent().show()
      @model.set 'displayName', @newName
      @model.save {},
        success: =>
          _gaq.push ['_trackEvent', 'datasets', 'rename', @newName]
        error: (model, xhr, options) =>
          $label.text @oldName
          @model.set 'displayName', @oldName
          Backbone.trigger 'error', model, xhr, options

  editableNameEscaped: (e) ->
    e.preventDefault()
    $('#editable-input input', @$el).val(@model.get "displayName").parent().hide().prev().show()

  keypressOnEditableName: (e) ->
    @editableNameBlurred(e) if e.keyCode is 13
    @editableNameEscaped(e) if e.keyCode is 27


class Cu.View.SignUpNav extends Backbone.View
  className: 'subnav-wrapper'

  initialize: (options) ->
    @options = options || {};

  render: ->
    humanPlan = @options.plan # eg: "freetrial"/"datascientist", passed in by router/main.coffee
    capitalisedPlan = humanPlan.toUpperCase()[0] + humanPlan.toLowerCase()[1..]
    if capitalisedPlan == 'Freetrial'
      capitalisedPlan = 'Free Trial'
    if capitalisedPlan == 'Datascientist'
      capitalisedPlan = 'Data Scientist'
    @$el.html JST['signupnav'] plan: capitalisedPlan
    window.document.title = "#{capitalisedPlan } | Sign Up | ScraperWiki"
    this


class Cu.View.HelpNav extends Backbone.View
  className: 'subnav-wrapper'

  initialize: (options) ->
    @options = options || {};

  render: ->
    window.document.title = @options.title or 'ScraperWiki'
    @$el.html JST['helpnav'] @options
    this



class Cu.View.ToolShopNav extends Backbone.View
  className: 'subnav-wrapper'

  initialize: (options) ->
    @options = options || {};
    
  render: ->
    window.document.title = "#{@options.name} | ScraperWiki"
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


