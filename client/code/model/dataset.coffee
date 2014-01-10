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
      autoFetch: true
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
        Backbone.trigger('error', null, {responseText: "Tool #{name} not found"}) unless tool?
        _.defer =>
          @fetch
            success: (dataset) =>
              existingTool = dataset.get('views').find (v) ->
                (v.get('tool') is tool) and (v.get('state') isnt 'deleted')

              if not existingTool?
                view = new Cu.Model.View
                  user: user.shortName
                  name: tool.get 'name'
                  displayName: tool.get('manifest').displayName
                  tool: tool
                @get('views').add view
                view.save wait:true,
                  success: (view) ->
                    callback null, view
                  error: (model, xhr, options) ->
                    Backbone.trigger 'error', model, xhr, options
                    callback xhr, null
              else
                callback 'already installed', null

      error: (model_, xhr_, err) =>
        callback err

  validate: (attrs) ->
    return "Please enter a name" if 'displayName' of attrs and attrs.displayName?.length < 1

  statusUpdatedHuman: ->
    updated = @get('status')?.updated
    if updated?
      return moment(updated).fromNow()
    else
      return 'Never'

  datasetCreatedHuman: ->
    created = @get('createdDate')
    if created?
      return moment(created).fromNow()
    else
      return 'Never'

  isVisible: ->
    @get('state') isnt 'deleted'

  destroy: (options) ->
    fiveMinutesInFuture = new Date(new Date().getTime() + 5 * 60000)
    @save {state: 'deleted', toBeDeleted: fiveMinutesInFuture}, options

  recover: ->
    @save {state: null, toBeDeleted: null}

Cu.Model.Dataset.setup()

class Cu.Collection.Datasets extends Backbone.Collection
  model: Cu.Model.Dataset
  name: 'Datasets'
  url: -> "/api/#{window.user.effective.shortName}/datasets"

  visible: ->
    visibles = @filter (t) -> t.isVisible()
    new Cu.Collection.Datasets visibles

  comparator: (model) ->
    d = model.get('createdDate') || '0001-01-01T00:00:00Z'
    u = new Date(d).getTime()
    "#{32472144000000 - u}|#{model.get('displayName')}"
