boxName = window.location.pathname.split('/')[1]
baseUrl = window.location.origin

exec = (cmd) ->
  settings = readSettings()
  $.ajax
    url: "#{baseUrl}/#{boxName}/exec"
    type: "POST"
    data:
      apikey: settings.source.apikey
      cmd: cmd

readSettings = ->
  return null if window.location.hash is ''
  hash = window.location.hash.substr(1)
  try
    settings = JSON.parse decodeURIComponent(hash)
  catch e
    return null
  return settings

