window.DatasetModel = class Dataset extends Backbone.Model
  idAttribute: '_id'
  url: "/api/#{window.user.shortName}/datasets"

window.DatasetListCollection = class DatasetList extends Backbone.Collection
  model: DatasetModel
  url: "/api/#{window.user.shortName}/datasets"
