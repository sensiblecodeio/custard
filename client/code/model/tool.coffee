class Cu.Model.Tool extends Backbone.RelationalModel
  urlRoot: "/api/tools"
  Cu.Boxable.mixin this

  idAttribute: 'name'

  isBasic: ->
    return @get('name') in ['spreadsheet-download', 'datatables-view-tool']

Cu.Model.Tool.setup()

class Cu.Collection.Tools extends Backbone.Collection
  model: Cu.Model.Tool
  url: "/api/tools/"

  importers: ->
    importers = @filter (t) -> t.get('type') is 'importer'
    new Cu.Collection.Tools importers

  nonimporters: ->
    nonimporters = @filter (t) -> t.get('type') isnt 'importer'
    new Cu.Collection.Tools nonimporters

  basics: ->
    basics = @filter (t) ->
      t.isBasic()
    new Cu.Collection.Tools basics

  comparator: (model) ->
    model.get('manifest')?.displayName

  findByName: (toolName) ->
    @find (tool) -> tool.get('name') is toolName
