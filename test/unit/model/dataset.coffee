mongoose = require 'mongoose'
_ = require 'underscore'
util = require 'util'
sinon = require 'sinon'
should = require 'should'
redis = require 'redis'
request = require 'request'


describe 'Client model: Dataset', ->
  helper = require '../helper'
  unless Cu.Model.Tool?
    helper.evalConcatenatedFile 'client/code/model/tool.coffee'
  unless Cu.Model.View?
    helper.evalConcatenatedFile 'client/code/model/view.coffee'
  unless Cu.Model.Dataset?
    helper.evalConcatenatedFile 'client/code/model/dataset.coffee'

  describe 'URL', ->
    beforeEach ->
      @box = 'blah'
      @tool = Cu.Model.Tool.findOrCreate
        name: 'test-app'
        manifest:
          displayName: 'Grr'

      @dataset = Cu.Model.Dataset.findOrCreate
        user: 'test'
        displayName: 'Dataset'
        box: @box
        tool: @tool

    it 'has an URL of /api/test/datasets/{id} if the dataset is new', ->
      @dataset.new = true
      @dataset.url().should.equal '/api/test/datasets'

    it 'has an URL of /api/test/datasets if the dataset is not new', ->
      @dataset.new = false # We shouldn't have to set this...
      @dataset.url().should.include @box

    xit 'has a related tool', ->
      tool = @dataset.get('tool')
      tool.get('displayName').should.equal 'Test App'

describe 'Server model: Dataset', ->

  Dataset = null

  before ->
    mongoose.connect process.env.CU_DB unless mongoose.connection.db

  before ->
    {Dataset} = require('model/dataset')

  before ->
    @vDataset = new Dataset
      name: 'test'
      box: 'box'
      tool: 'tool'
      displayName: 'Test'

  context 'when dataset.save is called', ->
    beforeEach ->
      @saveSpy = sinon.spy Dataset.dbClass.prototype, 'save'

    afterEach ->
      Dataset.dbClass.prototype.save.restore()
      @saveSpy = null

    it 'calls mongoose save method if all fields are valid', (done) ->
      @vDataset.save (err) =>
        @saveSpy.calledOnce.should.be.true
        done()

    # TODO:
    # What does invalid mean? tool doesn't exist?
    # user doesn't have access to tool?
    it "it doesn't call save if the tool is invalid", (done) ->
      @vDataset.tool = ''
      @vDataset.save =>
        @saveSpy.called.should.be.false
        done()

    it "it doesn't call save if the displayName is invalid", (done) ->
      @vDataset.displayName = ''
      @vDataset.save =>
        @saveSpy.called.should.be.false
        done()

    it "it doesn't call save if the box is invalid", (done) ->
      @vDataset.box = ''
      @vDataset.save =>
        @saveSpy.called.should.be.false
        done()

    it "it doesn't call save if the name is invalid", (done) ->
      @vDataset.name = ''
      @vDataset.save =>
        @saveSpy.called.should.be.false
        done()

  context 'when dataset.updateStatus is called', ->
    context 'with an error', ->
      before ->
        @saveSpy = sinon.spy Dataset.dbClass.prototype, 'save'

      after ->
        Dataset.dbClass.prototype.save.restore()

      before (done) ->
        @dataset = new Dataset
          name: 'test'
          box: 'box'
          tool: 'tool'
          displayName: 'Test'
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
        @saveSpy = sinon.spy Dataset.dbClass.prototype, 'save'
        # TODO: will actually connect to redis, stub properly
        @publishStub = sinon.stub Dataset.redisClient, 'publish'

      after ->
        Dataset.dbClass.prototype.save.restore()
        Dataset.redisClient.publish.restore()
        Dataset.redisClient.end()

      before (done) ->
        @dataset = new Dataset
          name: 'test'
          box: 'box'
          tool: 'tool'
          displayName: 'Test'
          views: [
            {box: 'foo'}
            {box: 'bar'}
          ]
        @dataset.updateStatus
          type: 'ok'
          message: 'I scrapped some page :D'
        , done

      it 'stores the status as ok', ->
        @dataset.status.type.should.equal 'ok'
        @dataset.status.message.should.eql 'I scrapped some page :D'

      it 'stores the current datetime', ->
        should.exist @dataset.status.updated
        (@dataset.status.updated instanceof Date).should.be.true

      it 'saves the status', ->
        @saveSpy.calledOnce.should.be.true

      it 'publishes the update to redis', ->
        channel = "#{process.env.NODE_ENV}.cobalt.dataset.box.updated"
        message = JSON.stringify
          boxes: ['foo', 'bar']
          message: 'I scrapped some page :D'

        published = @publishStub.calledWith channel, message
        published.should.be.true

    context 'with an unknown type', ->
      before ->
        @saveSpy = sinon.spy Dataset.dbClass.prototype, 'save'

      after ->
        Dataset.dbClass.prototype.save.restore()

      before (done) ->
        @dataset = new Dataset
          name: 'test'
          box: 'box'
          tool: 'tool'
          displayName: 'Test'
        @dataset.updateStatus
          type: 'unknown'
          message: 'what'
        , done

      it 'stores the status as ok', ->
        @dataset.status.type.should.equal 'ok'
        @dataset.status.message.should.eql 'what'

      it 'stores the current datetime', ->
        should.exist @dataset.status.updated
        (@dataset.status.updated instanceof Date).should.be.true

      it 'saves the status', ->
        @saveSpy.calledOnce.should.be.true

  context 'when dataset.findToBeDeleted is called', ->
    it 'returns datasets with toBeDeleted in the past', (done) ->
      Dataset.findToBeDeleted (err, datasets) ->
        datasets.length.should.equal 2
        done(err)

  context 'when dataset.cleanCrontab is called', ->
    before () ->
      @dataset = new Dataset
        user: 'zarino'
        box: '2416349265'

      @requestStub = sinon.stub request, 'post', (options, callback) ->
        callback null, {statusCode: 200}, {}

    it 'should call the exec endpoint correctly', (done) ->
      @dataset.cleanCrontab (err) =>
        calledCorrectly = @requestStub.calledWith
          uri: sinon.match /2416349265/
          form:
            apikey: 'zarino'
            cmd: sinon.match /crontab -r/
        calledCorrectly.should.be.true

        done()
