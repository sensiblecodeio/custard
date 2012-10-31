window.ToolModel = class ToolModel extends Backbone.Model
  base_url: 'http://boxecutor-dev-1.scraperwiki.net'

  install: (callback) ->
    @_create_box =>
      @_exec_cmd "cd; git clone #{@get 'git_url'}", callback

  setup: (callback) ->
    @_exec_cmd '~/setup', callback

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

