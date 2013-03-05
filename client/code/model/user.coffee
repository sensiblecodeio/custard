class Cu.Model.User extends Backbone.Model
  validate: (attrs) ->
    errors = {}
    if not @validDisplayName attrs
      errors.displayName = "This can only contain letters, numbers, spaces, dots and dashes"
    if not @validShortName attrs
      errors.shortName = "This can only contain letters, numbers, dots and dashes"
    if not @validEmail attrs
      errors.email = "This is not a valid email address"
    if _.size errors
      return errors

  validDisplayName: (attrs) ->
    'displayName' of attrs and /^[a-zA-Z0-9-. ]+$/g.test attrs.displayName

  validShortName: (attrs) ->
    'shortName' of attrs and /^[a-zA-Z0-9-.]+$/g.test attrs.shortName

  validEmail: (attrs) ->
    'email' of attrs and /^[a-zA-Z0-9-@.]+$/g.test attrs.email
