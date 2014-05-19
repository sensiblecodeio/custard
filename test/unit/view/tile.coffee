require '../setup_teardown'

sinon = require('sinon')
should = require('should')

helper = require '../helper'
unless Cu.View.DatasetTile?
  helper.evalConcatenatedFile 'client/code/view/dataset/tile.coffee'

describe "View: DatasetTile", ->
  beforeEach ->
    Model = Backbone.Model.extend({'recover': ->})
    model = new Model()
    sync = sinon.stub(model, 'sync')
    @save = sinon.stub(model, 'save')
    @destroy = sinon.stub(model, 'destroy')
    @recover = sinon.stub(model, 'recover')
    @view = new Cu.View.DatasetTile({model: model})

    @clock = sinon.useFakeTimers()

  afterEach ->
    @clock.restore()

  context "When hideDataset is called", ->
    it "model.destroy is called", ->
      @view.hideDataset(jQuery.Event())

      @destroy.calledOnce.should.be.true

    it "should setTimeout to remove tile after 5 minutes", ->
      @view.hideDataset(jQuery.Event())

      removeSpy = sinon.spy(@view, 'remove')

      @clock.tick 6 * 600000

      removeSpy.calledOnce.should.be.true

  context "When unhideDataset is called", ->
    it "model.destroy is called", ->
      @view.unhideDataset(jQuery.Event())

      @recover.calledOnce.should.be.true

    it "should clear the timeout", ->
      @view.hideDataset(jQuery.Event())
      @view.unhideDataset(jQuery.Event())

      removeSpy = sinon.spy(@view, 'remove')

      @clock.tick 6 * 600000

      removeSpy.called.should.be.false
