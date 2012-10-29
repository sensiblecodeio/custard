# Concatenate our JS and eval it
exports.evalConcatenatedFile = (filepath) ->
  Snockets = require 'snockets'
  snockets = new Snockets()
  js = snockets.getConcatenation filepath, async: false
  js = js.replace /^\(function\(\) {/gm, ''
  js = js.replace /^}\).call\(this\);/gm, ''

  eval.call global, js
