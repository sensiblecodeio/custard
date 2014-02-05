class Cu.Model.User extends Backbone.Model
  idAttribute: 'shortName'
  url: -> "/api/user/"

  #TODO: hack
  isNew: -> true

  validate: (attrs) ->
    errors = {}
    if not @validDisplayName attrs
      errors.displayName = "This can only contain letters, numbers, spaces, dots and dashes"
    if not @validShortName attrs
      errors.shortName = "This can only contain a minimum of 3, and a maximum of 24 letters, numbers, dots and dashes"
    if not @validEmail attrs
      errors.email = "This is not a valid email address"
    if not @hasAcceptedTerms attrs
      errors.acceptedTerms = "Please accept the terms and conditions"
    if _.size errors
      return errors

  validDisplayName: (attrs) ->
    if not 'displayName' of attrs
      return true
    else
      return /^[^<>;\b]+$/g.test attrs.displayName

  validShortName: (attrs) ->
    if not 'shortName' of attrs
      return true
    else
      return /^[a-zA-Z0-9-.]{3,24}$/g.test attrs.shortName

  validEmail: (attrs) ->
    if not 'email' of attrs
      return true
    else
      return /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]+$/gi.test attrs.email

  hasAcceptedTerms: (attrs) ->
    if not 'acceptedTerms' of attrs
      return true
    else
      return 0+attrs.acceptedTerms > 0

class Cu.Collection.User extends Backbone.Collection
  url: '/api/user'
  name: 'User'

  comparator: (model) ->
    model.get('displayName') or model.get('shortName')
