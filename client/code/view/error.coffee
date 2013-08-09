class Cu.View.Error extends Backbone.View
  className: "error-page"

  render: ->
    @el.innerHTML = """<p class="alert alert-error"><strong>#{@options.title}</strong> #{@options?.message}</p>"""
    @

class Cu.View.ErrorAlert extends Backbone.View
  events:
    'click button.close': 'hide'

  initialize: ->
    Backbone.on 'error', @onError, this

  render: (errorHTML) ->
    $('#fullscreen').css 'top': '173px'
    @$el.find('span').html errorHTML
    @$el.show()
    # http://stackoverflow.com/a/1145297/2653738
    $("html, body").animate scrollTop: 0
    @$el.fadeIn 300
    @

  hide: =>
    @$el.fadeOut 100

  onError: (message) ->
    @render message

  displayAJAXError: (event, jqXHR, ajaxSettings, thrownError) ->
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
