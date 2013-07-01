class Cu.Model.DataRequest extends Backbone.Model
  url: -> "/api/data-request/"

  validate: (attrs) ->
    errors = {}
    if not @validName attrs
      errors.name = "Please tell us your name"
    if not @validEmail attrs
      errors.email = "Please tell us your email address"
    if _.size errors
      return errors

  validName: (attrs) ->
    if not 'name' of attrs
      return true
    else
      return /^[^<>;]+$/g.test attrs.name

  validEmail: (attrs) ->
    if not 'email' of attrs
      return true
    else
      return /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]+$/gi.test attrs.email
