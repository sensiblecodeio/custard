class Cu.View.ToolContent extends Backbone.View

  initialize: ->
    Backbone.once 'tool:installed', @onInstalled, this

  render: ->
    @$el.html """<p class="loading">Loading tool</p>"""
    @model.install (ajaxObj, status) =>
      if status == 'success'
        @model.setup (buffer) =>
          @$el.html buffer.toString()
      else
        $('p.loading').text "Error: #{status}"

   onInstalled: ->
     console.log 'Tool has been installed. Creating dataset model...'
     user = window.user.effective
     dataset = new Cu.Model.Dataset
       user: user.shortName
       name: @model.get 'name'
       displayName: @model.get 'name'
       box: @model.get 'boxName'

     console.log 'Saving dataset model...'
     dataset.save {},
       wait: true
       success: ->
         console.log "Dataset saved (id: #{dataset.id})"
         window.app.navigate "/dataset/#{dataset.id}", {trigger: true}
       error: (model, xhr, options) ->
         console.log "Error saving dataset (xhr status: #{xhr.status} #{xhr.statusText})"
