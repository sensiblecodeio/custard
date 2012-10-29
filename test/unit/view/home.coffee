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

global.jQuery = global.$ = require('jquery').create window
global.Backbone = require 'backbone'
global.Backbone.setDomLibrary global.jQuery

eval(js)

describe 'Home page', ->
  context 'Header', ->

  context 'Content', ->
    before (done) ->
      tool = new Backbone.Model {id: 1, name: 'highrise'}
      @view = new HomeContentView model: tool
      sinon.stub @view.$el, 'load', (page) =>
        @view.$el.html '<div id="tile" class=".metro-tile"><p>Tile</p></div>'
        @view.renderTool()
        done()
      @view.render()

    after ->
      @view.$el.load.restore()

     it 'renders a single tile', ->
       @view.$el.find('#tile p').text().should.equal 'Tile'
       
     it 'renders the tool in the tile', ->
       t = @view.$el.find('.tool').first()
       should.exist t
       t.text().should.equal 'highrise'
     
     context 'when the tile is clicked', ->
       before ->
         @spy = sinon.spy @view, 'clickTile'
         tile = @view.$el.find('#tile').first()
         tile.click()

       it 'navigates to the tool page', ->
         @spy.calledOnce.should.be.true
