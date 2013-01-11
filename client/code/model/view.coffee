class Cu.Model.View extends Backbone.RelationalModel
  idAttribute: 'box'
  url: ->
    if @isNew()
      "/api/#{window.user.effective.shortName}/views"
    else
      "/api/#{window.user.effective.shortName}/views/#{@get 'box'}"

Cu.Model.View.setup()

class Cu.Model.ViewCollection extends Backbone.Collection
  model: Cu.Model.View
  url: -> "/api/#{window.user.effective.shortName}/views"
