class Cu.View.ToolTile extends Backbone.View
  className: 'tool'
  tagName: 'a'

  attributes: ->
    'data-nonpushstate': ''

  initialize: ->
    @model.on 'change', @render, this

  render: ->
    @monkeypatchIconManifest @model
    @$el.html JST['tool-tile'] @model.toJSON()
    @$el.addClass @model.get('name')
    @

  checkInstall: (e) ->
    @install(e) unless @active

  clicked: (e) ->
    e.stopPropagation()
    @checkInstall e

  # :TODO: Horrible kludge to avoid tool manifest changes right now (we've done worse)
  monkeypatchIconManifest: (model) ->
    manifest = model.get 'manifest'
    if manifest.displayName.indexOf('Code') == 0
      manifest.icon = '/image/tool-icon-code.png'
      manifest.color = '#555'
    else if manifest.displayName.indexOf('Twitter') > -1
      manifest.icon = '/image/tool-icon-twitter.png'
      manifest.color = '#3cf'
    else if manifest.displayName.indexOf('Upload') == 0
      manifest.icon = '/image/tool-icon-spreadsheet-upload.png'
      manifest.color = '#029745'
    else if manifest.displayName.indexOf('Test') == 0
      manifest.icon = '/image/tool-icon-test.png'
      manifest.color = '#b0df18'
    model.set 'manifest', manifest

class Cu.View.AppTile extends Cu.View.ToolTile
  events:
    'click' : 'clicked'

  install: (e) ->
    e.preventDefault()
    @active = true
    @$el.addClass 'loading'

    @model.install (jqXHR, text) =>
      user = window.user.effective
      dataset = Cu.Model.Dataset.findOrCreate
        user: user.shortName
        name: @model.get 'name'
        displayName: @model.get('manifest').displayName
        box: @model.get 'box'

      dataset.new = true

      dataset.save {},
        wait: true
        success: ->
          delete dataset.new
          window.app.navigate "/dataset/#{dataset.id}/settings", {trigger: true}
          $('#chooser').fadeOut 200, ->
            $(this).remove()
        error: (model, xhr, options) ->
          @active = false
          @$el.removeClass 'loading'
          console.warn "Error saving dataset (xhr status: #{xhr.status} #{xhr.statusText})"

class Cu.View.PluginTile extends Cu.View.ToolTile
  events:
    'click' : 'clicked'

  install: (e) ->
    e.preventDefault()
    @active = true

    @$el.addClass 'loading'
    dataset = Cu.Model.Dataset.findOrCreate
      user: window.user.effective.shortName
      box: @options.dataset.id

    dataset.fetch
      success: (dataset, resp, options) =>
        dataset.installPlugin @model.get('name'), (err, view) =>
          console.warn 'Error', err if err?
          window.app.navigate "/dataset/#{dataset.id}/view/#{view.id}", trigger: true
      error: (model, xhr, options) ->
        @active = false
        @$el.removeClass 'loading'
        console.warn xhr
