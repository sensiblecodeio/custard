class Cu.Model.Dataset extends Backbone.RelationalModel
  Cu.Boxable.mixin this

  idAttribute: 'box'
  relations: [
    {
      type: Backbone.HasMany
      key: 'views'
      relatedModel: Cu.Model.View
      collectionType: Cu.Collection.ViewList
      reverseRelation:
        key: 'plugsInTo'
        includeInJSON: 'box'
    }
    {
      type: Backbone.HasOne
      key: 'tool'
      relatedModel: Cu.Model.Tool
    }
  ]

  url: ->
    if @isNew()
      "/api/#{window.user.effective.shortName}/datasets"
    else
      "/api/#{window.user.effective.shortName}/datasets/#{@get 'box'}"

  isNew: ->
    @new

  name: ->
    @get('displayName') or @get('name') or 'no name'

  installPlugin: (name, callback) ->
    # get tool, install tool
    tools.fetch
      success: =>
        tool = window.tools.get name
        tool.install =>
          @get('views').add
            user: user.shortName
            name: tool.get 'name'
            displayName: tool.get('manifest').displayName
            box: tool.get 'box'
          @save {},
            success:=>
              newView = @get('views').findById tool.get 'box'
              callback null, newView
      error: (model_, xhr_, err) =>
        callback err

  validate: (attrs) ->
    return "Please enter a name" if 'displayName' of attrs and attrs.displayName?.length < 1

  statusUpdatedHuman: ->
    updated = @get('status')?.updated
    if updated?
      prettyDate(updated)
    else
      'Never'

Cu.Model.Dataset.setup()

class Cu.Collection.DatasetList extends Backbone.Collection
  model: Cu.Model.Dataset
  url: -> "/api/#{window.user.effective.shortName}/datasets"

  visible: ->
    visibles = @filter (t) -> t.get('state') isnt 'deleted'
    new Cu.Collection.DatasetList visibles

  comparator: (model) ->
    model.get 'displayName'
