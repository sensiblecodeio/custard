window.ToolModel = class ToolModel extends Backbone.Model
  setup: ->
    $.ajax
      type: 'POST'
      url: "http://box.scraperwiki.com/ehg.custard-backbone/exec"
      data:
        apikey: window.apikey
        cmd: './setup'

