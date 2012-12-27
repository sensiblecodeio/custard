sinon = require 'sinon'
should = require 'should'
helper = require '../helper'

helper.evalConcatenatedFile 'client/code/model/tool.coffee'
base_url = process.env.CU_BOX_SERVER
username = 'cotest'

describe 'Model: Tool', ->
  before ->
    @get = sinon.stub jQuery, 'get', (_url, callback) ->
      callback 'github.com/scraperwiki/highrise-tool.git'

    @tool = new Cu.Model.Tool
      name: 'highrise'

    @spy = sinon.spy @tool, '_generateBoxName'

  after ->
    jQuery.get.restore()
    @tool._generateBoxName.restore()

  it 'retrieves a git repo url', (done) ->
    @tool.git_url (url) ->
      url.should.include 'github.com/scraperwiki/highrise-tool.git'
      done()

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
          cmd: sinon.match /.*unzip master.*/

      called.should.be.true

  context 'when a tool is installed', ->
    it 'git clones the tool into the box'

  context 'when the setup function is called', ->
    before (done) ->
      ajaxObj =
        success: (cb) -> cb()
      @ajax = sinon.stub(jQuery, 'ajax').returns ajaxObj
      @tool.setup done

    after ->
      jQuery.ajax.restore()

    it 'execs the setup script in the box', ->
      called = @ajax.calledWith
        type: 'POST'
        url: "#{base_url}/#{@tool.get 'boxName'}/exec"
        data:
          apikey: sinon.match /.+/
          cmd: sinon.match /.*setup.*/

      called.should.be.true
