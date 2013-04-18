class Cu.Model.View extends Backbone.RelationalModel
  Cu.Boxable.mixin this

  idAttribute: 'box'
  relations: [
    {
      type: Backbone.HasOne
      key: 'tool'
      relatedModel: Cu.Model.Tool
      includeInJSON: 'name'
    }
  ]

  url: ->
    datasetId = @get('plugsInTo').get('box')
    if @isNew()
      "/api/#{window.user.effective.shortName}/datasets/#{datasetId}/views"
    else
      "/api/#{window.user.effective.shortName}/datasets/#{datasetId}/views/#{@get 'box'}"

  isVisible: ->
    @get('state') isnt 'deleted'

Cu.Model.View.setup()

class Cu.Collection.ViewList extends Backbone.Collection
  model: Cu.Model.View
  url: -> "/api/#{window.user.effective.shortName}/views"

  findById: (id) ->
    views = @find (t) -> t.id is id

  # returns first match
  findByToolName: (name) ->
    tool = app.tools().findByName name
    @findWhere tool: tool

  visible: ->
    visibles = @filter (t) -> t.isVisible()
    new Cu.Collection.ViewList visibles

  comparator: (model) ->
    model.get 'displayName'
