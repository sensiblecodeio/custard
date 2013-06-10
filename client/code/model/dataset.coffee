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
      includeInJSON: 'name'
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
    app.tools().fetch
      success: =>
        tool = app.tools().get name
        console.warn "tool #{name} not found" unless tool?
        view = new Cu.Model.View
          user: user.shortName
          name: tool.get 'name'
          displayName: tool.get('manifest').displayName
          tool: tool
        @get('views').add view
        view.save wait:true,
          success: (view) ->
            callback null, view
          error: (view, err) ->
            console.warn err
            callback err, null
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

  isVisible: ->
    @get('state') isnt 'deleted'

Cu.Model.Dataset.setup()

class Cu.Collection.Datasets extends Backbone.Collection
  model: Cu.Model.Dataset
  url: -> "/api/#{window.user.effective.shortName}/datasets"

  visible: ->
    visibles = @filter (t) -> t.isVisible()
    new Cu.Collection.Datasets visibles

  comparator: (model) ->
    model.get 'displayName'
