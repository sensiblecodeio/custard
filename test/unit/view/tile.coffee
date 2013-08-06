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

  context "When hideDataset is called", ->
    it "model.toBeDeleted is set to 5 mins in future", ->
      @view.hideDataset(jQuery.Event())

      @save.firstCall.args[0].toBeDeleted.should.be.instanceOf Date

      (@save.firstCall.args[0].toBeDeleted - new Date().getTime()).should.equal 5 * 60000

    it "model.state is set to 'deleted'", ->
      @view.hideDataset(jQuery.Event())

      @save.firstCall.args[0].state.should.equal 'deleted'

    it "should setTimeout to remove tile after 5 minutes", ->
      @view.hideDataset(jQuery.Event())

      removeSpy = sinon.spy(@view, 'remove')

      @clock.tick 6 * 600000

      removeSpy.calledOnce.should.be.true

  context "When unhideDataset is called", ->
    it "model.toBeDeleted is set to null", ->
      @view.unhideDataset(jQuery.Event())

      should.not.exist @save.firstCall.args[0].toBeDeleted

    it "model.state is set to null", ->
      @view.unhideDataset(jQuery.Event())

      should.not.exist @save.firstCall.args[0].state

    it "should clear the timeout", ->
      @view.hideDataset(jQuery.Event())
      @view.unhideDataset(jQuery.Event())

      removeSpy = sinon.spy(@view, 'remove')

      @clock.tick 6 * 600000

      removeSpy.called.should.be.false
