# TODO: Factor out Dataset from Tool
class Cu.Model.Tool extends Backbone.Model
  idAttribute: 'name'
  base_url: 'http://boxecutor-dev-0.scraperwiki.net'

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

  boxName: ->
    "#{window.user.shortName}/#{window.box}"

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
    boxname = @boxName()
    boxurl = "#{@base_url}/#{boxname}"
    settings =
      url: "#{boxurl}/exec"
      type: 'POST'
      data:
        apikey: window.user.apiKey
        cmd: cmd
    if args?
      $.extend settings, args
    $.ajax settings

  _create_box: ->
    $.ajax
      type: 'POST'
      url: "#{@base_url}/#{@boxName()}"
      data:
        apikey: window.user.apiKey

class Cu.Collection.Tools extends Backbone.Collection

