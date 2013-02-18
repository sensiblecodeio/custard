class Cu.View.DatasetTile extends Backbone.View
  className: 'dataset tile'
  tagName: 'a'
  attributes: ->
    if @options.details?
      href: "/dataset/#{@model.attributes.box}/settings"
    else
      href: "/dataset/#{@model.attributes.box}"
  
  events:
    'click .delete': 'hideDataset'

  initialize: ->
    @model.on 'change', @render, this

  render: ->
    @$el.html JST['dataset-tile']
      dataset: @model.toJSON()
      statusUpdatedHuman: @model.statusUpdatedHuman()
      user: window.user.effective
      views: @model.get('views').visible().toJSON()
    @

  hideDataset: (e) ->
    e.preventDefault()
    e.stopPropagation()
    @$el.parent().fadeOut()
    @model.save {state: 'deleted'},
      error: (e) =>
        @$el.parent().show()
        console.warn 'Dataset could not be deleted!'
