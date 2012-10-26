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

# Factor this stuff into functions as well
doc = jsdom '<html><body><div id="content">hi</div></body></html>'
window = doc.createWindow()
global.document = window.document
global.addEventListener = window.addEventListener

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
        @view.$el.html '<div id="tile">Tile</div>'
        done()
      @view.render()

    after ->
      @view.$el.load.restore()

     it 'renders a single tile', ->
       console.log $(@view).text()
       @view.$el.find('#tile').text().should.equal 'Tile'
       
     it 'renders the tool in the tile'
     
     context 'when the tile is clicked', ->
       it 'navigates to the tool page'

