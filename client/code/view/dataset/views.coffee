class Cu.View.DatasetViews extends Backbone.View
  className: 'dataset-views'

  render: ->
    views = @model.get('views').visible()
    if views.length > 0
      views.each @addView
    else
      if window.tools.length == 0
        window.tools.fetch
          success: =>
            window.tools.basics().each (tool) =>
              view = new Cu.View.PluginTile { model: tool, dataset: @model }
              @$el.append view.render().el
          error: =>
            @$el.append """<p class="alert alert-error">Sorry! The Tool Shop is currently unavailable.</p>"""
      else
        window.tools.basics().each (tool) =>
          view = new Cu.View.PluginTile { model: tool, dataset: @model }
          @$el.append view.render().el
    @

  addView: (view) =>
    v = new Cu.View.ViewTile model: view
    @$el.append v.render().el
