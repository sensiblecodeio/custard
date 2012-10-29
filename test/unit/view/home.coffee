fs = require 'fs'
sinon = require 'sinon'
should = require 'should'
{jsdom} = require 'jsdom'

# Concatenate our JS and eval it
# TODO: sweep this hack under the carpet
Snockets = require 'snockets'
snockets = new Snockets()
js = snockets.getConcatenation 'client/code/view/home_content.coffee', async: false
js = js.replace /^\(function\(\) {/gm, ''
js = js.replace /^}\).call\(this\);/gm, ''

# TODO: Factor this stuff into functions as well
doc = jsdom '<html><body><div id="content">hi</div></body></html>'
global.window = doc.createWindow()
global.document = global.window.document
global.addEventListener = global.window.addEventListener

global.jQuery = global.$ = require('jquery').create global.window
global.Backbone = require 'backbone'
global.Backbone.setDomLibrary global.jQuery

eval(js)

describe 'Home page', ->
  context 'Header', ->

  context 'Content', ->
    before (done) ->
      global.window.app = {navigate: ->}
      tool = new Backbone.Model {id: 1, name: 'hello-world'}
      @view = new HomeContentView model: tool
      sinon.stub @view.$el, 'load', (page) =>
        html = fs.readFileSync 'server/template/home_content.html', 'utf-8'
        @view.$el.html html
        @view.renderTool()
        done()
      @view.render()

    after ->
      @view.$el.load.restore()

     it 'renders the hello world tool', ->
       @view.$el.find('.metro-tile h3').first().text().should.equal 'hello-world'
       
     context 'when the tile is clicked', ->
       before ->
         @stub = sinon.stub global.window.app, 'navigate'
         @view.$el.find('.metro-tile').first().click()

       after ->
         global.window.app.navigate.restore()

       it 'navigates to the tool page', ->
         @stub.calledOnce.should.be.true
