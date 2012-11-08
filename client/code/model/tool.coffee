window.ToolModel = class ToolModel extends Backbone.Model

  base_url: 'http://boxecutor-dev-1.scraperwiki.net'

  git_url: (callback) ->
    $.get '/github_login', (login) =>
      login = login.replace '\n', ''
      callback "https://#{login}@github.com/scraperwiki/#{@get 'name'}-tool.git"

  install: (callback) ->
    @_create_box().success =>
      @git_url (url) =>
        @exec("cd; git clone #{url} #{@get 'name'}").success callback

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

  exec: (cmd) ->
    # Returns an ajax object, onto which you can
    # chain .success and .error callbacks
    boxname = @boxName()
    boxurl = "#{@base_url}/#{boxname}"
    $.ajax
      url: "#{boxurl}/exec"
      type: 'POST'
      data:
        apikey: window.apikey
        cmd: cmd

  _create_box: ->
    $.ajax
      type: 'POST'
      url: "#{@base_url}/#{@boxName()}"
      data:
        apikey: window.apikey
