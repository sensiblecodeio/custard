window.ToolContentView = class HomeContentView extends Backbone.View
  el: '#content'

  initialize: ->
    @render()

  render: ->
    @$el.empty()
    if @model.isInstalled()
      boxname = @model.boxName()
      boxurl = "#{@model.base_url}/#{boxname}"
      @model.publishToken (token) =>
        $('#content').html """<iframe src="#{boxurl}/#{token}/http/spreadsheet-tool/"></iframe>"""

    else
      @$el.html """<p class="loading">Loading #{@model.get 'name'} tool</p>"""
      @model.install (ajaxObj, status) =>
        if status == 'success'
          @model.setup (stuff) => @$el.html stuff
        else
          $('p.loading').text "Error: #{status}"
