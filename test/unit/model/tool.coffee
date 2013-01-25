sinon = require 'sinon'
should = require 'should'
helper = require '../helper'

helper.evalConcatenatedFile 'client/code/model/tool.coffee'
base_url = process.env.CU_BOX_SERVER
username = 'cotest'

describe 'Model: Tool', ->
  before ->
    @tool = new Cu.Model.Tool
      name: 'highrise'

    @spy = sinon.spy @tool, '_generateBoxName'

  after ->
    @tool._generateBoxName.restore()

  it 'can generate a random boxname', ->
    @tool._generateBoxName()
    name = @tool.get 'boxName'
    name.length.should.equal 7
    @tool._generateBoxName()
    name.should.not.equal @tool.get('boxName')

  context 'when a dataset tool is installed', ->
    before (done) ->
      ajaxObj =
        success: (cb) -> cb()
        complete: (cb) -> cb(null, 'success')

      @ajax = sinon.stub(jQuery, 'ajax').returns ajaxObj
      @tool.install done

    after ->
      jQuery.ajax.restore()

    it 'creates a box', ->
      called = @ajax.calledWith
        type: 'POST'
        url: "#{base_url}/box/#{@tool.get 'boxName'}"
        data:
          apikey: sinon.match /.+/

      called.should.be.true
      @spy.called.should.be.true

    it 'git clones the tool into the box', ->
      called = @ajax.calledWith
        type: 'POST'
        url: "#{base_url}/#{@tool.get 'boxName'}/exec"
        data:
          apikey: sinon.match /.+/
          cmd: sinon.match /.*git clone.*/

      called.should.be.true
