util = require 'util'
sinon = require 'sinon'
should = require 'should'


describe 'Client model: Dataset', ->
  helper = require '../helper'
  helper.evalConcatenatedFile 'client/code/app.coffee'
  describe 'URL', ->
    beforeEach ->
      @box = 'blah'
      obj = {user: 'test', box: @box}
      @dataset = Cu.Model.Dataset.findOrCreate obj

    it 'has an URL of /api/test/datasets/{id} if the dataset is new', ->
      @dataset.new = true
      @dataset.url().should.equal '/api/test/datasets'

    it 'has an URL of /api/test/datasets if the dataset is not new', ->
      @dataset.new = false # We shouldn't have to set this...
      @dataset.url().should.include @box

describe 'Server model: Dataset', ->
  class TestDb
    save: (callback) ->
      callback null

  Dataset = require('model/dataset')(TestDb)

  before ->
    @dataset = new Dataset name: 'test'

  context 'when dataset.save is called', ->
    before (done) ->
      @saveSpy = sinon.spy TestDb.prototype, 'save'
      @dataset.save done

    after ->
      TestDb.prototype.save.restore()
      @saveSpy = null

    it 'calls mongoose save method', ->
      @saveSpy.calledOnce.should.be.true

  context 'when dataset.updateStatus is called', ->
    context 'with an error', ->
      before ->
        @saveSpy = sinon.spy TestDb.prototype, 'save'

      after ->
        TestDb.prototype.save.restore()

      before (done) ->
        @dataset.updateStatus
          type: 'error'
          message: 'Scraper exception!!'
        , done

      it 'stores the status as an error', ->
        @dataset.status.type.should.equal 'error'
        @dataset.status.message.should.eql 'Scraper exception!!'

      it 'stores the current datetime', ->
        should.exist @dataset.status.updated
        (@dataset.status.updated instanceof Date).should.be.true

      it 'saves the status', ->
        @saveSpy.calledOnce.should.be.true

    context 'with an ok', ->
      before ->
        @saveSpy = sinon.spy TestDb.prototype, 'save'

      after ->
        TestDb.prototype.save.restore()

      before (done) ->
        @dataset.updateStatus
          type: 'ok'
          message: 'I scrapped some page :D'
        , done

      it 'stores the status as an error', ->
        @dataset.status.type.should.equal 'ok'
        @dataset.status.message.should.eql 'I scrapped some page :D'

      it 'stores the current datetime', ->
        should.exist @dataset.status.updated
        (@dataset.status.updated instanceof Date).should.be.true

      it 'saves the status', ->
        @saveSpy.calledOnce.should.be.true

    context 'with an unknown type', ->
      before ->
        @saveSpy = sinon.spy TestDb.prototype, 'save'

      after ->
        TestDb.prototype.save.restore()

      before (done) ->
        @dataset.updateStatus
          type: 'unknown'
          message: 'what'
        , done

      it 'stores the status as an error', ->
        @dataset.status.type.should.equal 'ok'
        @dataset.status.message.should.eql 'what'

      it 'stores the current datetime', ->
        should.exist @dataset.status.updated
        (@dataset.status.updated instanceof Date).should.be.true

      it 'saves the status', ->
        @saveSpy.calledOnce.should.be.true

