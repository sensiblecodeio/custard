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

# Call container iframe's API
scraperwiki.tool.redirect = (location) ->
  parent.scraperwiki.xdm.redirect(location)

scraperwiki.tool.getURL = (cb) ->
  parent.scraperwiki.xdm.getURL(cb)

scraperwiki.exec = (cmd, success, error) ->
  settings = scraperwiki.readSettings()
  options =
    url: "#{window.location.protocol}//#{window.location.host}/#{scraperwiki.boxName}/exec"
    type: "POST"
    data:
      apikey: settings.source.apikey
      cmd: cmd
  if success?
    options.success = success
  if error?
    options.error = error
  $.ajax options

scraperwiki.sql = (sql, success, error) ->
  settings = scraperwiki.readSettings()
  token = settings.token
  options =
    url: "#{window.location.protocol}//#{window.location.host}/#{scraperwiki.boxName}/#{token}/sqlite"
    type: "GET"
    dataType: "json"
    data:
      q: sql
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

