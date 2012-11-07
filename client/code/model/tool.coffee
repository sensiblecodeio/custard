window.ToolModel = class ToolModel extends Backbone.Model
  base_url: 'http://boxecutor-dev-1.scraperwiki.net'
  git_url: (callback) ->
    $.get '/github_login', (login) =>
      login = login.replace '\n', ''
      callback "https://#{login}@github.com/scraperwiki/#{@get 'name'}-tool.git"

  install: (callback) ->
    @_create_box =>
      @git_url (url) =>
        @_exec_cmd "cd; git clone #{url} #{@get 'name'}", callback

  setup: (callback) ->
    @_exec_cmd "cd;~/#{@get 'name'}/setup", callback

  isInstalled: ->
    name = @get 'name'
    datasets = JSON.parse($.cookie('datasets'))
    if datasets? and datasets[name]?
      return true
    return false

  boxName: ->
    name = @get 'name'
    datasets = JSON.parse($.cookie('datasets'))
    if datasets? and datasets[name]?
      return datasets[name]['box']

  _create_box: (callback) ->
    $.ajax
      type: 'POST'
      url: "#{@base_url}/cotest/#{@get 'box_name'}"
      data:
        apikey: window.apikey
      success: callback

  _exec_cmd: (cmd, callback) ->
    $.ajax
      type: 'POST'
      url: "#{@base_url}/cotest/#{@get 'box_name'}/exec"
      data:
        apikey: window.apikey
        cmd: cmd
      success: callback

