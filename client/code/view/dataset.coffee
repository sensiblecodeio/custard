class Cu.View.DataSet extends Backbone.View
  className: 'dataset'
  tagName: 'a'
  attributes: ->
    href: "/dataset/#{@model.attributes.box}"

  initialize: ->
    @model.on 'change', @render, this

  render: ->
    @$el.html JST['dataset']
      dataset: @model.toJSON()
      user: window.user.effective
    @
