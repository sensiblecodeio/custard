###
scraperwiki.js
Copyright (c) 2013 ScraperWiki Limited
ScraperWiki tool client library. See
http://x.scraperwiki.com/docs

jQuery is required.
###

# Can use short sw.tool.thing() or long scraperwiki.tool.thing()
scraperwiki = sw = { tool: {} }

scraperwiki.boxName = window.location.pathname.split('/')[1]
scraperwiki.baseUrl = window.location.origin

# Call container iframe's API
scraperwiki.tool.redirect = (location) ->
  parent.scraperwiki.xdm.redirect(location)

scraperwiki.tool.getURL = (cb) ->
  parent.scraperwiki.xdm.getURL(cb)

scraperwiki.exec = (cmd, success, error) ->
  settings = scraperwiki.readSettings()
  options =
    url: "#{scraperwiki.baseUrl}/#{scraperwiki.boxName}/exec"
    type: "POST"
    data:
      apikey: settings.source.apikey
      cmd: cmd
  if success?
    options.success = success
  if error?
    options.error = error
  $.ajax options

scraperwiki.readSettings = ->
  return null if window.location.hash is ''
  hash = window.location.hash.substr(1)
  try
    settings = JSON.parse decodeURIComponent(hash)
  catch e
    return null
  return settings

