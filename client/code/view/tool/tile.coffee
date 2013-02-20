class Cu.View.ToolTile extends Backbone.View
  className: 'tool'
  tagName: 'a'

  attributes: ->
    'data-nonpushstate': ''

  initialize: ->
    @model.on 'change', @render, this

  render: ->
    @$el.html JST['tool-tile'] @model.toJSON()
    @$el.addClass @model.get('name')
    @

  checkInstall: (e) ->
    @install(e) unless @active

  clicked: (e) ->
    e.stopPropagation()
    @checkInstall e

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
