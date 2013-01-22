refresh = (force) ->
  settings = $("#settings textarea").val()
  if settings isnt activeSettings or force is true
    activeSettings = settings
    $("h1").html baseUrl + "<span class=\"hash\">#" + encodeURIComponent(settings) + "</span>"
    
    # We have to completely regenerate the iframe, because
    # iframes don't reload when you only change their URL hash.
    $("iframe").replaceWith "<iframe src=\"" + baseUrl + "#" + encodeURIComponent(settings) + "\"></iframe>"
flashRefreshButton = ->
  $("#refresh").addClass "hover"
  setTimeout (->
    $("#refresh").removeClass "hover"
  ), 100
showSettings = ->
  $("#settings").show().children("textarea").focus()
hideSettings = ->
  $("#settings").hide()
exec = (cmd) ->
  $.ajax
    url: window.boxServer + "/" + window.boxName + "/exec"
    type: "POST"
    data:
      apikey: window.user.apiKey
      cmd: cmd

reinstall = ->
  exec("cd; for f in */setup; do $f;done").done((settings) ->
    refresh true
  ).fail (jqXHR, textStatus, errorThrown) ->
    alert "Ooops! Something went wrong. See javascript console for details."
    console.warn jqXHR.status, jqXHR.statusText, jqXHR.responseText, textStatus, errorThrown

$ ->
  activeSettings = null
  exec("cd; cat scraperwiki.json").done((data) ->
    settings = JSON.parse(data)
    baseUrl = window.boxServer + "/" + window.boxName + "/" + settings.publish_token + "/http"
    refresh true
  ).fail (jqXHR, textStatus, errorThrown) ->
    if errorThrown is "Not Found"
      $("h1").html "<b class=\"text-error\">Error!</b> Box &ldquo;" + window.boxName + "&rdquo; does not exist!"
    else if errorThrown is "Forbidden"
      $("h1").html "<b class=\"text-error\">Error!</b> Incorrect apikey for accessing box &ldquo;" + window.boxName + "&rdquo;!"
    else
      $("h1").html "<b class=\"text-error\">Error!</b> Something went wrong. See javascript console for details."
    console.warn jqXHR.status, jqXHR.statusText, jqXHR.responseText, textStatus, errorThrown

  obj =
    source:
      apikey: window.user.apiKey

    target:
      url: window.boxServer + "/boxname/publishtoken"

  $("textarea").val JSON.stringify(obj, null, 2)
  $(document).on "keydown", (e) ->
    if e.which is 82 and e.metaKey
      e.preventDefault()
      refresh true
      flashRefreshButton()
      false
    else if e.which is 27 and $("#settings").is(":visible")
      e.preventDefault()
      $("#settings textarea").blur()

  $("#refresh").on "click", ->
    refresh true

  $("#toggle-settings").on "click", (e) ->
    e.preventDefault()
    showSettings()  unless $("#settings").is(":visible")

  $("#settings textarea").on "blur", ->
    refresh()
    hideSettings()

  $("h1").on "click", ".hash", showSettings
  $("#reinstall").on "click", reinstall

