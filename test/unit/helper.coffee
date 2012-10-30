fakeWindow = ->
  {jsdom} = require 'jsdom'

  doc = jsdom '<html><body></body></html>'
  global.window = doc.createWindow()
  global.document = global.window.document
  global.addEventListener = global.window.addEventListener

  global.jQuery = global.$ = require('jquery').create global.window
  global.Backbone = require 'backbone'
  global.Backbone.setDomLibrary global.jQuery

fakeWindow()

# Concatenate our JS and eval it
exports.evalConcatenatedFile = (filepath) ->
  Snockets = require 'snockets'
  snockets = new Snockets()
  js = snockets.getConcatenation filepath, async: false
  js = js.replace /^\(function\(\) {/gm, ''
  js = js.replace /^}\).call\(this\);/gm, ''

  eval.call global, js
