class Cu.Model.View extends Backbone.RelationalModel
  idAttribute: 'box'
  url: ->
    if @isNew()
      "/api/#{window.user.effective.shortName}/views"
    else
      "/api/#{window.user.effective.shortName}/views/#{@get 'box'}"
      
  publishToken: (callback) ->
    if @_publishToken?
      callback @_publishToken
    else
      @exec("cat ~/scraperwiki.json").success (data) ->
        settings = JSON.parse data
        @_publishToken = settings.publish_token
        callback @_publishToken
  
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

Cu.Model.View.setup()

class Cu.Collection.ViewList extends Backbone.Collection
  model: Cu.Model.View
  url: -> "/api/#{window.user.effective.shortName}/views"
  findById: (id) ->
    views = @find (t) -> t.id is id
