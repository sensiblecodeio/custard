class Cu.View.DatasetViews extends Backbone.View
  className: 'dataset-views'

  render: ->
    views = @model.get('views').visible()
    if views.length > 0
      @$el.append '<h4>Analyse and export this data:</h4>'
      views.each @addView
    else
      @$el.append '<h4>Suggested tools to use on this data:</h4>'
      if window.tools.length == 0
        window.tools.fetch
          success: =>
            window.tools.basics().each (tool) =>
              view = new Cu.View.AppTile model: tool
              @$el.find('h4').after view.render().el
          error: =>
            @$el.find('h4').after """<p class="alert alert-error">Sorry! The Tool Shop is currently unavailable.</p>"""
      else
        window.tools.basics().each (tool) =>
          view = new Cu.View.AppTile model: tool
          @$el.append view.render().el
    @$el.append """<span class="btn btn-large new-view">See more tools&hellip;</span>"""
    @

  addView: (view) =>
    v = new Cu.View.ViewTile model: view
    @$el.append v.render().el
