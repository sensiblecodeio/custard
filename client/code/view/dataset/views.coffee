class Cu.View.DatasetViews extends Backbone.View
  className: 'dataset-views'

  render: ->
    views = @model.get('views').visible()
    if views.length > 0
      views.each @addView
    else
      if window.tools.length == 0
        console.log 'fetching tools'
        window.tools.fetch
          success: =>
            console.log 'tools fetched'
            window.tools.basics().each (tool) =>
              console.log 'tool:', tool
              view = new Cu.View.PluginTile { model: tool, dataset: @model }
              @$el.append view.render().el
          error: =>
            @$el.append """<p class="alert alert-error">Sorry! The Tool Shop is currently unavailable.</p>"""
      else
        console.log 'tools already fetched'
        window.tools.basics().each (tool) =>
          view = new Cu.View.PluginTile { model: tool, dataset: @model }
          @$el.append view.render().el
    @

  addView: (view) =>
    v = new Cu.View.ViewTile model: view
    @$el.append v.render().el
