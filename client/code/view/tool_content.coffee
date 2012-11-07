window.ToolContentView = class HomeContentView extends Backbone.View
  el: '#content'

  initialize: ->
    @render()

  render: ->
    if @model.isInstalled()
      boxname = @model.boxName()
      boxurl = "http://boxecutor-dev-1.scraperwiki.net/#{boxname}"
      $.ajax
        url: "#{boxurl}/exec"
        type: 'POST'
        dataType: 'json'
        data:
          apikey: apikey
          cmd: "cat ~/scraperwiki.json"
        success: (data) ->
          # :todo: is broken when no publishToken: fix.
          boxPublishToken = data.publish_token
          $('#content').html """<iframe src="#{boxurl}/#{boxPublishToken}/http/spreadsheet-tool/"></iframe>"""

    else
      @$el.html """<p class="loading">Loading #{@model.get 'name'} tool</p>"""
      @model.install =>
        @model.setup (stuff) => @$el.html stuff
