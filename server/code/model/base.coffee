_ = require 'underscore'

# All server models should extend this class.  All subclasses
# should ensure that they have defined a dbClass field that
# is the database class to use (when finding).  Typically
# this will be something like:
# @dbClass: mongoose.model 'User', userSchema
class ModelBase
  constructor: (obj) ->
    for k of obj
      @[k] = obj[k]

  objectify: ->
    # Prepare the object for transmission.  Converts it to a
    # plain old JavaScript object.  Any uninteresting fields
    # removed.
    res = {}
    for k of @
      res[k] = @[k]
    delete res.dbInstance
    return res

  save: (callback) ->
    if not @dbInstance?
      @dbInstance = new @constructor.dbClass(@)
      @id = @dbInstance._id
      @_id = @dbInstance._id #TODO: we should use ONE of these
    else
      for k of @dbInstance
        @dbInstance[k] = @[k] if @hasOwnProperty k
    @dbInstance.save callback

  @findAll: (callback) ->
    @dbClass.find {}, (err, docs) =>
      if err?
        console.warn err
        callback err, null
      if docs?
        result = for d in docs
          @makeModelFromMongo d
        callback null, result
      else
        callback null, null

  @makeModelFromMongo: (mongo_document) ->
    # Takes a Mongo document instance and returns an instance of this
    # model.

    # Note that this cool "new @" thing creates a fresh instance
    # of the same actual class of "this", which will in general
    # be some subclass of ModelBase.
    newModel = new @ {}
    newModel.dbInstance = mongo_document
    _.extend newModel, mongo_document.toObject()
    return newModel

module.exports = ModelBase
