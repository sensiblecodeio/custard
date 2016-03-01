require '../setup_teardown'

mongoose = require 'mongoose'
_ = require 'underscore'
util = require 'util'
sinon = require 'sinon'
should = require 'should'
request = require 'request'

describe 'Client model: Dataset', ->
  helper = require '../helper'
  unless Cu.Model.Tool?
    helper.evalConcatenatedFile 'client/code/model/tool.coffee'
  unless Cu.Model.View?
    helper.evalConcatenatedFile 'client/code/model/view.coffee'
  unless Cu.Model.Dataset?
    helper.evalConcatenatedFile 'client/code/model/dataset.coffee'
  helper.evalConcatenatedFile 'shared/vendor/js/moment.min.js'

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

  context "when model.destroy is called", ->
    before ->
      @dataset = new Cu.Model.Dataset
        user: 'zarino'
        box: '2416349265'

      @save = sinon.stub @dataset, 'save'

      @clock = sinon.useFakeTimers()

      @dataset.destroy()

    after ->
      @dataset.save.restore()

      @clock.restore()

    it "model.toBeDeleted is set to 5 mins in future", ->
      @save.firstCall.args[0].toBeDeleted.should.be.instanceOf Date

      (@save.firstCall.args[0].toBeDeleted - new Date().getTime()).should.equal 5 * 60000

    it "model.state is set to 'deleted'", ->
      @save.firstCall.args[0].state.should.equal 'deleted'

  context "when model.recover is called", ->
    before ->
      @dataset = new Cu.Model.Dataset
        user: 'zarino'
        box: '2416349266'

      @save = sinon.stub @dataset, 'save'

      @dataset.recover()

    after ->
      @dataset.save.restore()

    it "model.toBeDeleted is set to null", ->
      should.not.exist @save.firstCall.args[0].toBeDeleted

    it "model.state is set to null", ->
      should.not.exist @save.firstCall.args[0].state



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

      after ->
        Dataset.dbClass.prototype.save.restore()

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
          boxServer: "anExample-boxServer"
          user: "anExample-user"
          status: "anExample-status"
          boxJSON: "anExample-boxJSON"
          creatorShortName: "anExample-creatorShortName"
          creatorDisplayName: "anExample-creatorDisplayName"

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

  context "when dateset.statusUpdatedHuman is called", ->
    before ->
      @dataset = new Cu.Model.Dataset
        name: 'updateHumanTest'
        box: 'box24423'
        tool: 'tool'
        displayName: 'Update Human Test'
        status:
          type: 'ok'
          message: 'just testing'
          # status.updated is sufficiently old to test for
          # https://github.com/scraperwiki/custard/issues/364
          updated: "2013-04-12T11:00:57.847Z"
      @never = new Cu.Model.Dataset
        name: 'neverTest'
        box: 'box24243'
        tool: 'tool'
        displayName: 'Never Test'

    it "returns a human readable date", ->
      humanDate = @dataset.statusUpdatedHuman()
      should.equal typeof humanDate, 'string'
      humanDate.should.not.be.empty
      humanDate.should.include "ago"

    it """returns "Never" when there is no status""", ->
      humanDate = @never.statusUpdatedHuman()
      should.equal humanDate, "Never"
