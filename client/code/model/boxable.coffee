class Cu.Boxable
  publishToken: (callback) ->
    if @_publishToken?
      callback @_publishToken
    else
      @exec("cat ~/box.json", {dataType: 'json'}).success (settings) ->
        @_publishToken = settings.publish_token
        callback @_publishToken

  exec: (cmd, args) ->
    # Returns an ajax object, onto which you can
    # chain .success and .error callbacks
    boxurl = "#{window.boxServer}/#{@get 'box'}"
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

  @mixin: (klass) ->
    _.extend klass.prototype, @prototype
