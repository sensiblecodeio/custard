class Cu.Model.Tool extends Backbone.Model
  idAttribute: 'name'
  base_url: "#{window.boxServer}"

  install: (callback) ->
    @_create_box().complete (ajaxObj, status) =>
      if status != 'success'
        callback ajaxObj, status
      else
        @exec("cd; rm -r http && git clone #{@get 'gitUrl'} tool --depth 1 && ln -s tool/http http").complete callback

  publishToken: (callback) ->
    if @_publishToken?
      callback @_publishToken
    else
      @exec("cat ~/scraperwiki.json", {dataType: 'json'}).success (settings) ->
        @_publishToken = settings.publish_token
        callback @_publishToken

  exec: (cmd, args) ->
    # Returns an ajax object, onto which you can
    # chain .success and .error callbacks
    boxurl = "#{@base_url}/#{@get 'boxName'}"
    settings =
      url: "#{boxurl}/exec"
      type: 'POST'
      dataType: 'text'
      data:
        apikey: window.user.effective.apiKey
        cmd: cmd
    if args?
      $.extend settings, args
    $.ajax settings

  _create_box: ->
    @_generateBoxName()
    $.ajax
      type: 'POST'
      url: "#{@base_url}/box/#{@get 'boxName'}"
      data:
        apikey: window.user.effective.apiKey

  _generateBoxName: ->
    r = Math.random() * Math.pow(10,9)
    n = Nibbler.b32encode(String.fromCharCode(r>>24,(r>>16)&0xff,(r>>8)&0xff,r&0xff)).replace(/[=]/g,'').toLowerCase()
    @set 'boxName', n

class Cu.Collection.Tools extends Backbone.Collection
  model: Cu.Model.Tool
  url: -> "/api/tools/"

  importers: ->
    importers = @filter (t) -> t.get('type') is 'importer'
    new Cu.Collection.Tools importers

  nonimporters: ->
    nonimporters = @filter (t) -> t.get('type') isnt 'importer'
    new Cu.Collection.Tools nonimporters

  comparator: (model) ->
    model.get('manifest')?.displayName
