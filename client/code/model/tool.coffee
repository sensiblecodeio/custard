class Cu.Model.Tool extends Backbone.RelationalModel
  urlRoot: "/api/tools"
  Cu.Boxable.mixin this

  idAttribute: 'name'

  isBasic: ->
    return @get('name') in ['spreadsheet-download', 'datatables-view-tool']

  isImporter: ->
    return @get('type') is 'importer'

Cu.Model.Tool.setup()

class Cu.Collection.Tools extends Backbone.Collection
  model: Cu.Model.Tool
  url: "/api/tools/"
  name: 'Tools'

  importers: ->
    importers = @filter (t) -> t.isImporter()
    new Cu.Collection.Tools importers

  nonimporters: ->
    nonimporters = @filter (t) -> not t.isImporter()
    new Cu.Collection.Tools nonimporters

  basics: ->
    basics = @filter (t) ->
      t.isBasic()
    new Cu.Collection.Tools basics

  comparator: (model) ->
    model.get('manifest')?.displayName

  findByName: (toolName) ->
    @find (tool) -> tool.get('name') is toolName
