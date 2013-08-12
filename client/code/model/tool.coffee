class Cu.Model.Tool extends Backbone.RelationalModel
  urlRoot: "/api/tools"
  Cu.Boxable.mixin this

  idAttribute: 'name'

  isBasic: ->
    return @get('name') in ['spreadsheet-download', 'datatables-view-tool']

  isImporter: ->
    return @get('type') is 'importer'

  # :TODO: Horrible kludge to avoid tool manifest changes right now
  initialize: ->
    @on 'add change', =>
      manifest = @get('manifest')
      n = manifest.displayName.toLowerCase()
      if n.indexOf('test') == 0
        manifest.icon = 'https://s3-eu-west-1.amazonaws.com/sw-icons/tool-icon-test.png'
        manifest.color = '#b0df18'
      @set 'manifest', manifest

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
