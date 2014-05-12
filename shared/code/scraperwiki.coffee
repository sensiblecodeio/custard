###
scraperwiki.js 2
Copyright (c) 2013 ScraperWiki Limited
ScraperWiki tool client library. See
https://scraperwiki.com/help

jQuery is required.
###

window.console = window.console or
  log: ->

scraperwiki = sw =
  dataset: {}
  tool: {}
  user: {}
  reporting: {}


scraperwiki.box = window.location.pathname.split('/')[1]


scraperwiki.alert = (title, message, level=0) ->
  ###
  [title] and [message] should be html strings. The first is displayed in bold.
  If [level] is a truthful value, the alert is printed in red.
  ###
  $a = $('<div>').addClass('alert').prependTo('body')
  $a.addClass('alert-error') if level
  $a.html """<button type="button" class="close" data-dismiss="alert">&times;</button> <strong>#{title}</strong> #{message}"""


scraperwiki.readSettings = ->
  ###
  Returns dataset and tool settings from the current tool's URL hash
  ###
  try
    # Try the hash from the current window
    return JSON.parse(decodeURIComponent(window.location.hash.substr(1)))
  catch e
    try
      # Try the hash from the container, if it has one?
      return JSON.parse(decodeURIComponent(parent.location.hash.substr(1)))
    catch e
  return null


scraperwiki.url = (arg) ->
  ###
  [arg] should either be a string (to redirect the browser),
  a callback function (which will be passed the current url),
  or undefined, in which case a jQuery deferred object is
  returned, on which you can call .done() and .always()
  ###
  if typeof(arg) is 'string'
    # they want to set the url (ie: redirect)
    parent.scraperwiki.xdm.redirect(arg)
  else
    # they want to retrieve the current url
    dfd = new jQuery.Deferred()
    if typeof(arg) is 'function'
      parent.scraperwiki.xdm.getURL arg
    else
      parent.scraperwiki.xdm.getURL dfd.resolve
    return dfd.promise()


scraperwiki.dataset.name = (arg) ->
  ###
  [arg] should either be a string (to set the dataset's name),
  a function (to get the dataset's current name, and pass it
  to the callback function),
  or undefined, in which case we get the dataset's current name
  and pass it to a jQuery deferred object.
  ###
  if typeof(arg) is 'string'
    if scraperwiki.readSettings().target?
      # Uh-oh, we're in a "view", which we can't rename
      console.log('Unable to rename tool. Currently only datasets can be renamed.')
    else
      parent.scraperwiki.xdm.rename(scraperwiki.box, arg)
  else
    dfd = new jQuery.Deferred()
    if typeof(arg) is 'function'
      arg null, scraperwiki.readSettings().target.displayName
    else
      dfd.resolve scraperwiki.readSettings().target.displayName
    return dfd.promise()


scraperwiki.dataset.sql = (sql, success, error) ->
  ###
  Execute a SQL query on the main dataset.
  [success] and [error] callbacks are optional,
  since this returns a jQuery deferred object on which
  you can chain .done() and .fail() handlers.
  ###
  settings = scraperwiki.readSettings()
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


scraperwiki.dataset.sql.meta = (success, error) ->
  ###
  Get info about the main dataset's SQL database.
  [success] and [error] callbacks are optional,
  since this returns a jQuery deferred object on which
  you can chain .done() and .fail() handlers.
  ###
  settings = scraperwiki.readSettings()
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


scraperwiki.dataset.installTool = (query, toolName) ->
  ###
  Passes the specified [query] to the specified [toolName],
  installing it into the current dataset if necessary.
  ###
  parent.scraperwiki.xdm.pushSQL(query, toolName)


scraperwiki.tool.name = (arg) ->
  ###
  [arg] should either be a string (to set the tool's name),
  a function (to get the tool's current name, and pass it
  to the callback function),
  or undefined, in which case we get the tool's current name
  and pass it to a jQuery deferred object.
  ###
  if typeof(arg) is 'string'
    # we can't currently rename a tool; only a dataset!!
    # parent.scraperwiki.xdm.rename(scraperwiki.box, arg)
  else
    # we can't currently get the tool's current name,
    # so we return a placeholder.
    dfd = new jQuery.Deferred()
    if typeof(arg) is 'function'
      arg 'under construction', null
    else
      dfd.reject 'under construction'
    return dfd.promise()


scraperwiki.tool.sql = (sql, success, error) ->
  ###
  Execute a SQL query on the tool's own internal database.
  [success] and [error] callbacks are optional,
  since this returns a jQuery deferred object on which
  you can chain .done() and .fail() handlers.
  ###
  settings = scraperwiki.readSettings()
  options =
    url: "#{settings.source.url}/sql/"
    type: "GET"
    dataType: "json"
    data:
      q: sql
  if success?
    options.success = success
  if error?
    options.error = error
  $.ajax options


scraperwiki.tool.sql.meta = (success, error) ->
  ###
  Get info about this tool's internal SQL database.
  [success] and [error] callbacks are optional,
  since this returns a jQuery deferred object on which
  you can chain .done() and .fail() handlers.
  ###
  settings = scraperwiki.readSettings()
  options =
    url: "#{settings.source.url}/sql/meta"
    type: "GET"
    dataType: "json"
  if success?
    options.success = success
  if error?
    options.error = error
  $.ajax options


scraperwiki.tool.exec = (cmd, success, error) ->
  ###
  Execute a unix command inside this tool's box.
  [success] and [error] callbacks are optional,
  since this returns a jQuery deferred object on which
  you can chain .done() and .fail() handlers.
  ###
  settings = scraperwiki.readSettings()
  options =
    url: "#{window.location.protocol}//#{window.location.host}/#{scraperwiki.box}/exec"
    type: "POST"
    dataType: "text"
    data:
      apikey: settings.source.apikey
      cmd: cmd
    complete: ->
      scraperwiki.tool.exec.pending -= 1
      if scraperwiki.tool.exec.pending is 0
        $(document).trigger('execsComplete')
  if success?
    options.success = success
  if error?
    options.error = error
  scraperwiki.tool.exec.pending += 1
  if scraperwiki.tool.exec.pending is 1
    $(document).trigger('execsPending')
  $.ajax options

scraperwiki.tool.exec.pending = 0


scraperwiki.shellEscape = (command) ->
  ###
  Useful for making variables "safe" for inclusion in exec commands.
  ###
  "'#{command.replace(/'/g,"'\"'\"'")}'"


scraperwiki.user.profile = (success) ->
  ###
  Get the current user's shortName and displayName.
  An object containing the details will be passed to
  the optional [success] callback function. This function
  also returns a jQuery deferred object on which you can
  chain a .done() handler which is given the user details too.
  ###
  dfd = new jQuery.Deferred()
  parent.scraperwiki.xdm.getUserDetails (userDetails) ->
    if typeof(success) is 'function'
      success userDetails
    dfd.resolve userDetails
  return dfd.promise()


scraperwiki.reporting.message = (message, success, error) ->
  ###
  Send a message from the current user to Intercom, our reporting package
  ###
  dfd = new jQuery.Deferred()
  if typeof success is 'function'
    dfd.done(success)
  if typeof error is 'function'
    dfd.fail(error)

  parent.scraperwiki.xdm.reportingMessage message, dfd.resolve, dfd.reject
  return dfd.promise()


scraperwiki.reporting.user = (payload, success, error) ->
  ###
  Communicate user payload data to the /user/ intercom endpoint
  ###
  dfd = new jQuery.Deferred()
  if typeof success is 'function'
    dfd.done(success)
  if typeof error is 'function'
    dfd.fail(error)

  parent.scraperwiki.xdm.reportingUser payload, dfd.resolve, dfd.reject
  return dfd.promise()


scraperwiki.reporting.tag = (tagname, success, error) ->
  ###
  Tag the user with `tagname`
  ###
  dfd = new jQuery.Deferred()
  if typeof success is 'function'
    dfd.done(success)
  if typeof error is 'function'
    dfd.fail(error)

  parent.scraperwiki.xdm.reportingTag tagname, dfd.resolve, dfd.reject
  return dfd.promise()


# HERE BE DEPRECATED FUNCTIONS:

scraperwiki.tool.pushSql = scraperwiki.tool.pushSQL = scraperwiki.dataset.installTool
scraperwiki.tool.rename = scraperwiki.dataset.name
scraperwiki.tool.getUrl = scraperwiki.tool.getURL = scraperwiki.tool.redirect = scraperwiki.url
scraperwiki.sql = scraperwiki.dataset.sql
scraperwiki.sql.meta = scraperwiki.dataset.sql.meta
scraperwiki.exec = scraperwiki.tool.exec
scraperwiki.exec.pending = scraperwiki.tool.exec.pending
