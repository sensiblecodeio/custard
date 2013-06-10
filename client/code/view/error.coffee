class Cu.View.Error extends Backbone.View
  className: "error-page"

  render: ->
    @el.innerHTML = """<p class="alert alert-error"><strong>#{@options.title}</strong> #{@options?.message}</p>"""
    @
