class Cu.Model.Dataset extends Backbone.RelationalModel
  idAttribute: 'box'
  relations: [
    type: Backbone.HasMany
    key: 'views'
    relatedModel: 'Cu.Model.View'
    collectionType: 'Cu.Model.ViewCollection'
    reverseRelation:
      key: 'plugsInTo'
      includeInJSON: 'box'
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

  publishToken: (callback) ->
    if @_publishToken?
      callback @_publishToken
    else
      @exec("cat ~/scraperwiki.json").success (data) ->
        settings = JSON.parse data
        @_publishToken = settings.publish_token
        callback @_publishToken

  installPlugin: (name, callback) ->
    # get tool, install tool
    tools.fetch
      success: =>
        tool = window.tools.get name
        tool.install =>
          @get('views').add
            user: user.shortName
            name: tool.get 'name'
            displayName: tool.get 'name'
            box: tool.get 'boxName'
          @save()
          newView = @get('views').findById tool.get 'boxName'
          callback null, newView
      error: (model_, xhr_, err) =>
        callback err

  exec: (cmd, args) ->
    # Returns an ajax object, onto which you can
    # chain .success and .error callbacks
    boxname = @get 'box'
    boxurl = "#{window.boxServer}/#{boxname}"
    settings =
      url: "#{boxurl}/exec"
      type: 'POST'
      data:
        apikey: window.user.effective.apiKey
        cmd: cmd
    if args?
      $.extend settings, args
    $.ajax settings

  validate: (attrs) ->
    return "Please enter a name" if 'displayName' of attrs and attrs.displayName?.length < 1

Cu.Model.Dataset.setup()

class Cu.Collection.DatasetList extends Backbone.Collection
  model: Cu.Model.Dataset
  url: -> "/api/#{window.user.effective.shortName}/datasets"

