window.ToolModel = class ToolModel extends Backbone.Model

  base_url: 'http://boxecutor-dev-1.scraperwiki.net'

  git_url: (callback) ->
    $.get '/tpl/github_login', (login) =>
      login = login.replace '\n', ''
      callback "https://#{login}@github.com/scraperwiki/#{@get 'name'}-tool.git"

  zip_url: (callback) ->
    $.get '/tpl/github_login', (login) =>
      login = login.replace '\n', ''
      callback "https://#{login}@github.com/scraperwiki/#{@get 'name'}-tool/archive/master.zip"

  install: (callback) ->
    @_create_box().success =>
      @zip_url (url) =>
        n = @get 'name'
        @exec("cd; curl -L -O #{url}; unzip master.zip; mv #{n}-tool-master #{n}").success callback

  setup: (callback) ->
    @exec("cd;~/#{@get 'name'}/setup").success callback

  isInstalled: ->
    name = @get 'name'
    datasets = JSON.parse $.cookie('datasets')
    if datasets? and datasets[name]?
      return true
    return false

  boxName: ->
    name = @get 'name'
    datasets = JSON.parse $.cookie('datasets')
    if datasets? and datasets[name]?
      return datasets[name]['box']
    else
      # :todo: Make this suck less
      return 'cotest/' + window.box

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
        apikey: window.apikey
        cmd: cmd
    if args?
      $.extend settings, args
    $.ajax settings

  _create_box: ->
    $.ajax
      type: 'POST'
      url: "#{@base_url}/#{@boxName()}"
      data:
        apikey: window.apikey
