sinon = require 'sinon'
should = require 'should'
helper = require '../helper'

helper.evalConcatenatedFile 'client/code/model/tool.coffee'

describe 'Tool Model', ->
  before ->
    @tool = new ToolModel {name: 'hello-world'}
    window.apikey = 'a-test-apikey'

  context 'when a dataset tool is installed', ->
    it 'creates a box'
    it 'git clones the tool into the box'

  context 'when a tool is installed', ->
    it 'git clones the tool into the box'

  context 'when the setup function is called', ->
    before ->
      @ajax = sinon.stub jQuery, 'ajax'
      @tool.setup()

    it 'execs the setup script in the box', ->
      called = @ajax.calledWith
        type: 'POST'
        url: "http://box.scraperwiki.com/ehg.custard-backbone/exec"
        data:
          apikey: sinon.match /.+/
          cmd: sinon.match /.*.\/setup.*/

      called.should.be.true
