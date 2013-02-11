class Cu.Model.View extends Backbone.RelationalModel
  Cu.Boxable.mixin this

  idAttribute: 'box'
  url: ->
    if @isNew()
      "/api/#{window.user.effective.shortName}/views"
    else
      "/api/#{window.user.effective.shortName}/views/#{@get 'box'}"

Cu.Model.View.setup()

class Cu.Collection.ViewList extends Backbone.Collection
  model: Cu.Model.View
  url: -> "/api/#{window.user.effective.shortName}/views"

  findById: (id) ->
    views = @find (t) -> t.id is id

  visible: ->
    visibles = @filter (t) -> t.get('state') isnt 'deleted'
    new Cu.Collection.ViewList visibles

  comparator: (model) ->
    model.get 'displayName'
