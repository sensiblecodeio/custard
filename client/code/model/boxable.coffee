class Cu.Boxable
  publishToken: (callback) ->
    if @_publishToken?
      callback @_publishToken
    else
      @exec "cat ~/box.json",
        dataType: 'json'
        success: (settings) ->
          @_publishToken = settings.publish_token
          callback @_publishToken
        error: (jqXhr, textStatus, errorThrown) ->
          console.warn "Couldn't parse box.json!", errorThrown


  exec: (cmd, args) ->
    # Returns an ajax object, onto which you can
    # chain .success and .error callbacks
    boxurl = "#{@endpoint()}/#{@get 'box'}"
    settings =
      url: "#{boxurl}/exec"
      type: 'POST'
      dataType: 'text'
      data:
        apikey: window.user.effective.apiKey
        cmd: cmd
    if args?
      $.extend settings, args
    $.ajax settings

  endpoint: ->
    server = @get('boxServer') or @get('server')
    #TODO: stop poluting the global namespace
    if window.custardEnvironment is 'production'
      "https://#{server}"
    else
      "http://#{server}"


  @mixin: (klass) ->
    _.extend klass.prototype, @prototype
