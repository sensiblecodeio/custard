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
        dataset.installPlugin @options.archetype.get('name'), (err, view) =>
          console.warn 'Error', err if err?
          v = new Cu.View.ToolMenuItem model: view
          el = v.render().el
          $('a', el).addClass('active')
          $('#toolbar .tool.active').removeClass("active")
          $('#toolbar .tools').append el
          window.app.navigate "/dataset/#{dataset.id}/view/#{view.id}", trigger: true
      error: (model, xhr, options) ->
        @active = false
        console.warn xhr
