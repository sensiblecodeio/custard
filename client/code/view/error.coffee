class Cu.View.Error extends Backbone.View
  className: "error-page"

  render: ->
    @el.innerHTML = """<p class="alert alert-error"><strong>#{@options.title}</strong> #{@options?.message}</p>"""
    @

class Cu.View.ErrorAlert extends Backbone.View
  initialize: ->
    $(document).ajaxError @displayAJAXError
    Backbone.on 'error', @onError, this

  render: (errorHTML) ->
    $('#fullscreen').css 'top': '173px'
    @$el.find('span').html errorHTML
    # http://stackoverflow.com/a/1145297/2653738
    $("html, body").animate scrollTop: 0
    @$el.fadeOut 100, =>
      @$el.fadeIn 300
    @

  hide: =>
    @$el.hide()

  onError: (message, response) =>
    if typeof message is 'string'
      @render message
    else
      @render JSON.parse(response.responseText).error

  displayAJAXError: (event, jqXHR, ajaxSettings, thrownError) =>
    message = "xhr.statusText: #{jqXHR.statusText}"
    # Possibly translate the error into a more helpful error
    # message to display.
    # 0 is connection refused (don't normally get these except
    # when developing because we front with nginx).
    # 502 is Bad Gateway which nginx will serve when custard is
    # basically dead (or starting up).
    # 504 is Gateway Timeout, this will happen if a custard request times out
    if jqXHR?.status in [0, 502, 504]
      message = "Sorry! We couldn't connect to the server, please try again."
      return @render message
