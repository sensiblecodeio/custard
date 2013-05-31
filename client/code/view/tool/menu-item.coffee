# This should be passed a dataset/view model, not a tool archetype model
class Cu.View.ToolMenuItem extends Backbone.View
  tagName: 'li'
  events:
    'click .hide': 'hideTool'
    'click .ssh-in': (event) ->
      event.preventDefault()
      event.stopPropagation()
      if @model instanceof Cu.Model.Dataset
        showOrAddSSH @model, 'dataset'
      else if @model instanceof Cu.Model.View
        showOrAddSSH @model, 'view'

  hideTool: (e) ->
    e.preventDefault()
    e.stopPropagation()
    if @model instanceof Cu.Model.View
      $('.hide', @$el).hide 0, =>
        @$el.slideUp =>
          dataset = @model.get('plugsInTo')
          @model.set 'state', 'deleted'
          dataset.save()
          app.navigate "/dataset/#{dataset.get 'box'}/", trigger: true

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
          window.app.navigate "/dataset/#{dataset.id}/view/#{view.id}", trigger: true
      error: (model, xhr, options) ->
        @active = false
        console.warn xhr
