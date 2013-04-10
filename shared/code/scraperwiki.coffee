###
scraperwiki.js
Copyright (c) 2013 ScraperWiki Limited
ScraperWiki tool client library. See
http://x.scraperwiki.com/docs

jQuery is required.
###

# Can use short sw.tool.thing() or long scraperwiki.tool.thing()
scraperwiki = sw = { tool: {} }

scraperwiki.box = window.location.pathname.split('/')[1]

# Call container iframe's API
scraperwiki.tool.redirect = (location) ->
  parent.scraperwiki.xdm.redirect(location)

scraperwiki.tool.getURL = (cb) ->
  parent.scraperwiki.xdm.getURL(cb)

scraperwiki.tool.rename = (name) ->
  parent.scraperwiki.xdm.rename(scraperwiki.box, name)

scraperwiki.tool.pushSQL = (query, toolName) ->
  parent.scraperwiki.xdm.pushSQL(query, toolName)

scraperwiki.exec = (cmd, success, error) ->
  settings = scraperwiki.readSettings()
  options =
    url: "#{window.location.protocol}//#{window.location.host}/#{scraperwiki.box}/exec"
    type: "POST"
    dataType: "text"
    data:
      apikey: settings.source.apikey
      cmd: cmd
  if success?
    options.success = success
  if error?
    options.error = error
  $.ajax options

scraperwiki.shellEscape = (command) ->
  "'#{command.replace(/'/g,"'\"'\"'")}'"

scraperwiki.sql = (sql, success, error) ->
  settings = scraperwiki.readSettings()
  # Points to the dataset box, when used from either the dataset or a view.
  boxSettings = settings.target ? settings.source
  options =
    url: "#{boxSettings.url}/sql/"
    type: "GET"
    dataType: "json"
    data:
      q: sql
  if success?
    options.success = success
  if error?
    options.error = error
  $.ajax options

scraperwiki.sql.meta = (success, error) ->
  settings = scraperwiki.readSettings()
  # Points to the dataset box, when used from either the dataset or a view.
  boxSettings = settings.target ? settings.source
  options =
    url: "#{boxSettings.url}/sql/meta"
    type: "GET"
    dataType: "json"
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

scraperwiki.alert = (title, message, level=0) ->
  # [title] and [message] should be html strings. The first is displayed in bold.
  # If [level] is a truthful value, the alert is printed in red.
  $a = $('<div>').addClass('alert').prependTo('body')
  $a.addClass('alert-error') if level
  $a.html """<button type="button" class="close" data-dismiss="alert">&times;</button> <strong>#{title}</strong> #{message}"""
