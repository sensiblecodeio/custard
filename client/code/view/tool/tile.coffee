class Cu.View.ToolTile extends Backbone.View
  className: 'tool'
  tagName: 'a'
  initialize: ->
    @model.on 'change', @render, this

  render: ->
    @$el.html JST['tool-tile'] @model.toJSON()
    @

class Cu.View.AppTile extends Cu.View.ToolTile
  attributes: ->
    href: "/tool/#{@model.get 'name'}"

class Cu.View.PluginTile extends Cu.View.ToolTile
  events:
    'click' : 'install'

  attributes: ->
    'data-nonpushstate': ''

  install: (e) ->
    e.preventDefault()
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
        @$el.removeClass 'loading'
        console.warn xhr
