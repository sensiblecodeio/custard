class Cu.Model.Dataset extends Backbone.Model
  idAttribute: '_id'
  url: -> "/api/#{window.user.shortName}/datasets"

class Cu.Collection.DatasetList extends Backbone.Collection
  model: Cu.Model.Dataset
  url: -> "/api/#{window.user.shortName}/datasets"
