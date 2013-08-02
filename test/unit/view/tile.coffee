sinon = require('sinon')
should = require('should')

helper = require '../helper'
unless Cu.View.DatasetTile?
  helper.evalConcatenatedFile 'client/code/view/dataset/tile.coffee'

describe "View: DatasetTile", ->
  beforeEach ->
    model = new Backbone.Model()
    sync = sinon.stub(model, 'sync')
    @save = sinon.stub(model, 'save')
    @view = new Cu.View.DatasetTile({model: model})

    @clock = sinon.useFakeTimers()

  afterEach ->
    @clock.restore()

  it "model.toBeDeleted is set to 5 mins in future when hideDataset is called", ->
    @view.hideDataset(jQuery.Event())

    @save.firstCall.args[0].toBeDeleted.should.be.instanceOf Date

    (@save.firstCall.args[0].toBeDeleted - new Date().getTime()).should.equal 5 * 60000

  it "model.state is set to 'deleted' when hideDateset is called", ->
    @view.hideDataset(jQuery.Event())

    @save.firstCall.args[0].state.should.equal 'deleted'

  it "model.toBeDeleted is set to null when unhideDataset is called", ->
    @view.unhideDataset(jQuery.Event())

    should.not.exist @save.firstCall.args[0].toBeDeleted

  it "model.state is set to null when unhideDataset is called", ->
    @view.unhideDataset(jQuery.Event())

    should.not.exist @save.firstCall.args[0].state
