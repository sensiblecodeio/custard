class Cu.Boxable
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
    "https://#{server}"


  @mixin: (klass) ->
    _.extend klass.prototype, @prototype
