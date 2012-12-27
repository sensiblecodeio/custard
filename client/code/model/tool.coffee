class Cu.Model.Tool extends Backbone.Model
  idAttribute: 'name'
  base_url: "#{window.boxServer}"

  git_url: (callback) ->
    $.get '/github-login', (login) =>
      login = login.replace '\n', ''
      callback "https://#{login}@github.com/scraperwiki/#{@get 'name'}-tool.git"

  zip_url: (callback) ->
    $.get '/github-login', (login) =>
      login = login.replace '\n', ''
      callback "https://#{login}@github.com/scraperwiki/#{@get 'name'}-tool/archive/master.zip"

  install: (callback) ->
    @_create_box().complete (ajaxObj, status) =>
      if status != 'success'
        callback ajaxObj, status
      else
        @zip_url (url) =>
          n = @get 'name'
          @exec("cd; curl -L -O #{url}; unzip master.zip; mv #{n}-tool-master #{n}").complete callback

  setup: (callback) ->
    @exec("cd;~/#{@get 'name'}/setup").success callback

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
    # HACK: Set this here so the tool code can have access to it
    # our box messaging API (using easyXDM) should take care of this
    window.box = n

class Cu.Collection.Tools extends Backbone.Collection
  importers: ->
    importers = @filter (t) -> t.get('type') is 'importer'
    new Cu.Collection.Tools importers
