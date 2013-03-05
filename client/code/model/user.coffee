class Cu.Model.User extends Backbone.Model
  validate: (attrs) ->
    return 'invalid name' unless @validDisplayName attrs
    return 'invalid username' unless @validShortName attrs
    return 'invalid email' unless @validEmail attrs

  validDisplayName: (attrs) ->
    'displayName' of attrs and /^[a-zA-Z0-9- ]+$/g.test attrs.displayName

  validShortName: (attrs) ->
    'shortName' of attrs and /^[a-zA-Z0-9-]+$/g.test attrs.shortName

  validEmail: (attrs) ->
    'email' of attrs and /^[a-zA-Z0-9-@.]+$/g.test attrs.email
