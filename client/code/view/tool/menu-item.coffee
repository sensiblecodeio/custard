# This should be passed a dataset/view model, not a tool archetype model
class Cu.View.ToolMenuItem extends Backbone.View
  tagName: 'li'
  events:
    'click .hide': 'hideTool'
    'click .git-ssh': ->
      Cu.Helpers.showOrAddSSH @model.get('box'), @model.get('displayName'), 'dataset'

  hideDataset: (e) ->
    e.preventDefault()
    e.stopPropagation()
    @$el.slideUp()
    @model.save {state: 'deleted'}

  initialize: ->
    @model.on 'change', @render, this
    app.tools().on 'fetched', @render, this

  render: =>
    if app.tools().length
      @a = $('<a>').appendTo @$el
      @a.html @model.get('tool').get('manifest').displayName
      if @model instanceof Cu.Model.Dataset
        @a.attr 'href', "/dataset/#{@model.get 'box'}/settings"
      else
        @a.attr 'href', "/dataset/#{@model.get('plugsInTo').get('box')}/view/#{@model.get 'box'}"
    @
