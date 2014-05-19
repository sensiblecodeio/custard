require './setup_teardown'

fakeWindow = ->
  {jsdom} = require 'jsdom'

  doc = jsdom '<html><body></body></html>'
  global.window = doc.createWindow()
  global.document = global.window.document
  global.addEventListener = global.window.addEventListener
  window = global.window

  global.jQuery = global.$ = require('jquery').create global.window
  global.$.cookie = -> null
  global._ = window._ = require 'underscore'
  global.Backbone = window.Backbone = require 'backbone'
  global.BackboneRelational = window.BackboneRelational = require 'backbone-relational'
  global.Backbone.$ = global.$

  # Disable BR warnings we don't care about if we're unit testing
  #global.Backbone.Relational.showWarnings = false

  exports.evalConcatenatedFile "client/code/namespace.coffee"
  exports.evalConcatenatedFile "client/code/model/boxable.coffee"


  auser =
    shortName: 'test'
    apiKey: 'fakeapikey'
    email: 'test@example.com'
    displayName: 'Tesuto Tesoto-San'

  global.user =
    effective: auser
    real: auser

  global.boxServer = process.env.CU_BOX_SERVER

# Concatenate our JS and eval it
exports.evalConcatenatedFile = (filepath) ->
  Snockets = require 'snockets'
  snockets = new Snockets()
  js = snockets.getConcatenation filepath, async: false
  js = js.replace /^\(function\(\) {/gm, ''
  js = js.replace /^}\).call\(this\);/gm, ''
  js = js.replace /window\./g, 'global.' # hack, so namespacing works

  eval.call global, js

fakeWindow()
