handleError = (old) ->
  ->
    args = _.toArray arguments
    if args.length == 0
      options = {}
      args.push  options
    else
      options = args[args.length - 1] || {}
    unless options.error?
      options.error = (collection, response, options) ->
        Backbone.trigger 'error', collection, response, options
    old.apply this, args

patchErrors = ->
  Backbone.Collection.prototype.fetch = handleError Backbone.Collection.prototype.fetch
  Backbone.Model.prototype.save = handleError Backbone.Model.prototype.save
  Backbone.Model.prototype.fetch = handleError Backbone.Model.prototype.fetch

window.Cu.Util.patchErrors = patchErrors
