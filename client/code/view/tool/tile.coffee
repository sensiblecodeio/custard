class Cu.View.ToolTile extends Backbone.View
  className: 'tool swcol'
  tagName: 'a'

  attributes: ->
    'data-nonpushstate': ''

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
    n = manifest.displayName.toLowerCase()
    if n.indexOf('in your browser') > -1
      manifest.icon = '/image/tool-icon-classic.png'
      manifest.color = '#6AAFD1'
    else if n.indexOf('code') == 0
      manifest.icon = '/image/tool-icon-code.png'
      manifest.color = '#555'
    else if n.indexOf('twitter') > -1 or n.indexOf('tweet') > -1
      manifest.icon = '/image/tool-icon-twitter.png'
      manifest.color = '#3cf'
    else if n.indexOf('upload') == 0
      manifest.icon = '/image/tool-icon-spreadsheet-upload.png'
      manifest.color = '#029745'
    else if n.indexOf('download') == 0
      manifest.icon = '/image/tool-icon-spreadsheet-upload.png'
      manifest.color = '#029745'
    else if n.indexOf('test') == 0
      manifest.icon = '/image/tool-icon-test.png'
      manifest.color = '#b0df18'
    else if n.indexOf('table') > -1
      manifest.icon = '/image/tool-icon-data-table.png'
      manifest.color = '#f6b730'
    else if n.indexOf('query with sql') == 0
      manifest.icon = '/image/tool-icon-sql.png'
      manifest.color = '#17959d'
    model.set 'manifest', manifest

  showLoading: ->
    $inner = @$el.find('.tool-icon-inner')
    $inner.empty().css('background-image', 'none')
    Spinners.create($inner, {
      radius: 7,
      height: 8,
      width: 2.5,
      dashes: 12,
      opacity: 1,
      padding: 3,
      rotation: 1000,
      color: '#fff'
    }).play()

class Cu.View.AppTile extends Cu.View.ToolTile
  events:
    'click' : 'clicked'

  install: (e) ->
    e.preventDefault()
    @active = true
    @showLoading()
    @createDataset()

  # TODO: DRY with RPC call
  createDataset: ->
    dataset = Cu.Model.Dataset.findOrCreate
      displayName: @model.get('manifest').displayName
      tool: @model
    app.datasets().add dataset
    dataset.new = true
    dataset.save {},
      wait: true
      success: ->
        delete dataset.new
        # TODO: this should be removed when we sort out the tool/view/dataset refactor
        # Install the datatables view tool here
        dataset.installPlugin 'datatables-view-tool', (err, view) ->
          console.warn 'Error', err if err?
        window.app.navigate "/dataset/#{dataset.id}/settings", {trigger: true}
        $('#chooser').fadeOut 200, ->
          $(this).remove()
      error: (model, xhr, options) ->
        @active = false
        console.warn "Error creating dataset (xhr status: #{xhr.status} #{xhr.statusText})"

class Cu.View.PluginTile extends Cu.View.ToolTile
  events:
    'click' : 'clicked'

  install: (e) ->
    e.preventDefault()
    @active = true
    @showLoading()

    dataset = Cu.Model.Dataset.findOrCreate
      user: window.user.effective.shortName
      box: @options.dataset.id

    dataset.fetch
      success: (dataset, resp, options) =>
        dataset.installPlugin @model.get('name'), (err, view) =>
          console.warn 'Error', err if err?
          window.app.navigate "/dataset/#{dataset.id}/view/#{view.id}", trigger: true
          $('#chooser').fadeOut 200, ->
            $(this).remove()
      error: (model, xhr, options) ->
        @active = false
        @$el.removeClass 'loading'
        console.warn xhr
