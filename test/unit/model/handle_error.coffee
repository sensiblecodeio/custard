sinon = require 'sinon'
should = require 'should'
helper = require '../helper'

helper.evalConcatenatedFile 'client/code/util.coffee'

describe "handleError", ->
  context "when we call fetch on a model", ->
    beforeEach ->
      @myFetch = sinon.stub()
      Backbone.Collection.prototype.fetch = @myFetch
      Cu.Util.patchErrors()

      MyCollection = Backbone.Collection.extend({
      })
      @myCollection = new MyCollection()

    it "should add a error handler to the options if one isn't present", ->
      options = {}
      @myCollection.fetch()

      @myFetch.firstCall.args[0].error.should.not.be.null

    it "should not add a error handler to the options if one is present", ->
      errorHandler = sinon.stub()
      options = {error: errorHandler}
      @myCollection.fetch options

      @myFetch.firstCall.args[0].error.should.equal errorHandler

  context "when we call save on a model", ->
    beforeEach ->
      @mySave = sinon.stub()
      Backbone.Model.prototype.save = @mySave
      patchErrors()

      MyModel = Backbone.Model.extend({
      })
      @myModel = new MyModel()

    it "should add a error handler to the options if one isn't present", ->
      options = {}
      @myModel.save {}, options

      @mySave.firstCall.args[1].error.should.not.be.null

    it "should not add a error handler to the options if one is present", ->
      errorHandler = sinon.stub()
      options = {error: errorHandler}
      @myModel.save {}, options

      @mySave.firstCall.args[1].error.should.equal errorHandler

  context "when we call fetch on a model", ->
    beforeEach ->
      @myFetch = sinon.stub()
      Backbone.Model.prototype.fetch = @myFetch
      patchErrors()

      MyModel = Backbone.Model.extend({
      })
      @myModel = new MyModel()

    it "should add a error handler to the options if one isn't present", ->
      options = {}
      @myModel.fetch options

      @myFetch.firstCall.args[0].error.should.not.be.null

    it "should not add a error handler to the options if one is present", ->
      errorHandler = sinon.stub()
      options = {error: errorHandler}
      @myModel.fetch options

      @myFetch.firstCall.args[0].error.should.equal errorHandler
