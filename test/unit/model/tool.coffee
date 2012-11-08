sinon = require 'sinon'
should = require 'should'
helper = require '../helper'

helper.evalConcatenatedFile 'client/code/model/tool.coffee'
base_url = "http://boxecutor-dev-1.scraperwiki.net"
username = 'cotest'

describe 'Model: Tool', ->
  before ->
    num = String(Math.random()).replace '.',''
    @tool = new ToolModel
      name: 'highrise'

    sinon.stub(@tool, 'boxName').returns \
      'cotest/highrise-' + num.substring(num.length, num.length - 4)

    @get = sinon.stub jQuery, 'get', (_url, callback) ->
      callback 'github.com/scraperwiki/highrise-tool.git'

    window.apikey = 'a-test-apikey'

  after ->
    jQuery.get.restore()

  it 'retrieves a git repo url', (done) ->
    @tool.git_url (url) ->
      url.should.include 'github.com/scraperwiki/highrise-tool.git'
      done()

  context 'when a dataset tool is installed', ->
    before (done) ->
      ajaxObj =
        success: (cb) -> cb()

      @ajax = sinon.stub(jQuery, 'ajax').returns ajaxObj
      @tool.install done

    after ->
      jQuery.ajax.restore()

    it 'creates a box', ->
      called = @ajax.calledWith
        type: 'POST'
        url: "#{base_url}/#{@tool.boxName()}"
        data:
          apikey: sinon.match /.+/

      called.should.be.true

    it 'git clones the tool into the box', ->
      called = @ajax.calledWith
        type: 'POST'
        url: "#{base_url}/#{@tool.boxName()}/exec"
        data:
          apikey: sinon.match /.+/
          cmd: sinon.match /.*git clone.*/

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
        url: "#{base_url}/#{@tool.boxName()}/exec"
        data:
          apikey: sinon.match /.+/
          cmd: sinon.match /.*setup.*/

      called.should.be.true
