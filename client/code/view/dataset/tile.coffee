class Cu.View.DatasetTile extends Backbone.View
  className: 'dataset'
  tagName: 'a'
  attributes: ->
    if @options.details?
      href: "/dataset/#{@model.attributes.box}/settings"
    else
      href: "/dataset/#{@model.attributes.box}"

  initialize: ->
    @model.on 'change', @render, this

  render: ->
    @$el.html JST['dataset-tile']
      dataset: @model.toJSON()
      user: window.user.effective
    @
