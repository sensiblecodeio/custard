class Cu.View.ToolContent extends Backbone.View
  el: '#content'

  initialize: ->
    @on 'tool:installed', @onInstalled, this
    @render()

  render: ->
    @$el.empty()
    if false #@model.isInstalled()
      boxname = @model.boxName()
      boxurl = "#{@model.base_url}/#{boxname}"
      @model.publishToken (token) =>
        $('#content').html """<iframe src="#{boxurl}/#{token}/http/spreadsheet-tool/"></iframe>"""

    else
      @$el.html """<p class="loading">Loading #{@model.get 'name'} tool</p>"""
      @model.install (ajaxObj, status) =>
        if status == 'success'
          @model.setup (buffer) =>
            @$el.html buffer.toString()
        else
          $('p.loading').text "Error: #{status}"

   onInstalled: ->
     user = window.user
     dataset = new Cu.Model.Dataset
       user: user.shortName
       name: "#{@model.get 'name'}"
       box: @model.boxName()

     dataset.save()
