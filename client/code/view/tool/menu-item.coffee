# This should be passed a dataset/view model, not a tool archetype model
class Cu.View.ToolMenuItem extends Backbone.View
  tagName: 'li'
  events:
    'click .dropdown-toggle': 'showOptionsDropdown'

  showOptionsDropdown: (e) ->
    e.stopPropagation()
    e.preventDefault()
    if $('#tool-options-menu').is(':visible')
      $('#tool-options-menu, #dropdown-menu-closer').hide()
      $('body').off 'click.showOptionsDropdown'
    else
      toggleOffset = $(e.currentTarget).offset()
      toolbarOffset = $('#toolbar').offset()
      top = toggleOffset.top - toolbarOffset.top
      left = toggleOffset.left - toolbarOffset.left
      right = $('#toolbar').width() - left
      $('#tool-options-menu').css(
        top: top + 25
        right: right - 35
        left: 'auto'
      ).show()
      $('#dropdown-menu-closer').show()
      $('body').on 'click.showOptionsDropdown', ->
        $('#tool-options-menu, #dropdown-menu-closer').hide()
        $('body').off 'click.showOptionsDropdown'

  render: ->
    hideable = true
    toolName = @model.get('tool').get('name')
    manifest = @model.get('tool').get('manifest')

    if toolName is 'newview'
      manifest.displayName = @model.get('displayName')

    if @model instanceof Cu.Model.Dataset
      href = "/dataset/#{@model.get 'box'}/settings"
      hideable = false
    else
      href = "/dataset/#{@model.get('plugsInTo').get('box')}/view/#{@model.get 'box'}"

    if toolName is "datatables-view-tool"
      hideable = false

    html = JST['toolbar-tile']
      manifest: manifest
      href: href
      id: "instance-#{@model.get 'box'}"
      hideable: hideable
      toolName: toolName
    @$el.html html
    @

# This should be passed a tool archetype model, not a dataset/view model
class Cu.View.ArchetypeMenuItem extends Backbone.View
  tagName: 'li'

  initialize: ->
    @options.archetype.on 'change', @render, this

  events:
    'click a': 'clicked'

  render: ->
    if app.tools().length
      html = JST['toolbar-tile']
        manifest: @options.archetype.get 'manifest'
        toolName: @options.archetype.get 'name'
      @$el.html html
    @

  clicked: (e) ->
    e.stopPropagation()
    @install(e) unless @active

  # Copied from client/code/view/tool/tile.coffee
  install: (e) ->
    e.preventDefault()
    @active = true
    $('#content').html """<p class="loading">Installing tool&hellip;</p>"""

    dataset = Cu.Model.Dataset.findOrCreate
      user: window.user.effective.shortName
      box: @options.dataset.id

    dataset.fetch
      success: (dataset, resp, options) =>
        toolName = @options.archetype.get 'name'
        dataset.installPlugin toolName, (err, view) =>
          unless err == 'already installed'
            Backbone.trigger('error', null, """{"responseText": "#{err}"}""") if err?
            v = new Cu.View.ToolMenuItem model: view
            el = v.render().el
            $('#toolbar .tool.active').removeClass("active")
            $('a', el).addClass('active')
            $('#toolbar .tools').append el
            $("ul.archetypes a[data-toolname='#{toolName}']").parent().remove()
            _gaq.push ['_trackEvent', 'tools', 'install', toolName]
            _gaq.push ['_trackEvent', 'views', 'create']
            window.app.navigate "/dataset/#{dataset.id}/view/#{view.id}", trigger: true
          else
            # this will probably only ever happen for the View in a table tool
            # since that's the only suggested "archetype" that's installed secretly
            # in the background.
            # we wait 4 seconds, and pretend the tool is installing
            # because it probably still is, in the background.
            poll = (dataset) =>
              timeout = setTimeout =>
                view = dataset.get('views').findWhere(tool: @options.archetype)
                if view.get('state') is 'installed'
                  menuItem = new Cu.View.ToolMenuItem model: view
                  el = menuItem.render().el
                  $('#toolbar .tool.active').removeClass("active")
                  $('a', el).addClass('active')
                  $('#toolbar .tools').append el
                  $("ul.archetypes a[data-toolname='#{toolName}']").parent().remove()
                  clearTimeout timeout
                  window.app.navigate "/dataset/#{dataset.id}/view/#{view.id}", trigger: true
                else
                  dataset.fetch success: (dataset) -> poll dataset
              , 1000

            poll dataset

      error: (model, xhr, options) ->
        @active = false
        Backbone.trigger 'error', model, xhr, options
