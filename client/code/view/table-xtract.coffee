class Cu.View.TableXtract extends Backbone.View
  className: 'table-xtract'
  events:
    'click #hero a[href="#try-it-out"]': (e) ->
      e.preventDefault()
      _gaq.push ['_trackEvent', 'table-xtract', 'cta-button-click']
      $('html, body').animate
        scrollTop: $('#try-it-out').offset().top - 40
      , 250, ->
        $('#try-it-out input').focus()
    'focus #try-it-out input': (e) ->
      _gaq.push ['_trackEvent', 'table-xtract', 'email-form-focus']
    'submit #try-it-out form': (e) ->
      _gaq.push ['_trackEvent', 'table-xtract', 'email-form-submit', $('#try-it-out input').val()]

  render: ->
    @el.innerHTML = JST['table-xtract']()
    @setUpYouTube()
    @

  setUpYouTube: ->
    tag = document.createElement('script')

    tag.src = "https://www.youtube.com/iframe_api"
    firstScriptTag = document.getElementsByTagName('script')[0]
    firstScriptTag.parentNode.insertBefore tag, firstScriptTag

    window.onYouTubeIframeAPIReady = ->
      window.player = new YT.Player 'youtube-video',
        height: '390'
        width: '640'
        videoId: 'ErcKL_lfrpE'
        events:
          onStateChange: window.onPlayerStateChange

    window.onPlayerStateChange = (event) ->
      if event.data is YT.PlayerState.PLAYING
        _gaq.push ['_trackEvent', 'table-xtract', 'video-play']
      else if event.data is YT.PlayerState.PAUSED
        _gaq.push ['_trackEvent', 'table-xtract', 'video-pause']
      else if event.data is YT.PlayerState.ENDED
        _gaq.push ['_trackEvent', 'table-xtract', 'video-finished']
