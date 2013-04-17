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
    @on 'add', =>
      manifest = @get('manifest')
      n = manifest.displayName.toLowerCase()
      if n.indexOf('in your browser') > -1
        manifest.icon = '/image/tool-icon-classic.png'
        manifest.color = '#6AAFD1'
      else if n.indexOf('code') == 0
        manifest.icon = '/image/tool-icon-code.png'
        manifest.color = '#555'
      else if n.indexOf('twitter') > -1 or n.indexOf('tweet') > -1
        manifest.icon = '/image/tool-icon-twitter.png'
        manifest.color = '#3cf'
      else if n.indexOf('upload') == 0
        manifest.icon = '/image/tool-icon-spreadsheet-upload.png'
        manifest.color = '#029745'
      else if n.indexOf('download') == 0
        manifest.icon = '/image/tool-icon-spreadsheet-upload.png'
        manifest.color = '#029745'
      else if n.indexOf('test') == 0
        manifest.icon = '/image/tool-icon-test.png'
        manifest.color = '#b0df18'
      else if n.indexOf('table') > -1
        manifest.icon = '/image/tool-icon-data-table.png'
        manifest.color = '#f6b730'
      else if n.indexOf('query with sql') == 0
        manifest.icon = '/image/tool-icon-sql.png'
        manifest.color = '#17959d'
      @set 'manifest', manifest

Cu.Model.Tool.setup()

class Cu.Collection.Tools extends Backbone.Collection
  model: Cu.Model.Tool
  url: "/api/tools/"

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
