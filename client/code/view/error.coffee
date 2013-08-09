class Cu.View.Error extends Backbone.View
  className: "error-page"

  render: ->
    @el.innerHTML = """<p class="alert alert-error"><strong>#{@options.title}</strong> #{@options?.message}</p>"""
    @

class Cu.View.ErrorAlert extends Backbone.View
  render: (errorHTML) ->
    @el.innerHTML = """<p class="container">#{errorHTML}</p>"""
    @$el.show()
    # http://stackoverflow.com/a/1145297/2653738
    $("html, body").animate scrollTop: 0
    @

  displayAJAXError: (event, jqXHR, ajaxSettings, thrownError) ->
    message = "xhr.statusText: #{jqXHR.statusText}"
    # Possibly translate the error into a more helpful error
    # message to display.
    # 0 is connection refused (don't normally get these except
    # when developing because we front with nginx).
    # 502 is Bad Gateway which nginx will serve when custard is
    # basically dead (or starting up).
    if jqXHR?.status in [0, 502]
      message = "Connection Refused to #{ajaxSettings.url}"
    return @render message
