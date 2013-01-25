Browser = require 'zombie'
should = require 'should'

url = 'http://localhost:3001'
login_url = "#{url}/login"

describe 'Home page (logged in)', ->
  browser = new Browser()
  browser.waitDuration = "10s"

  before (done) ->
    browser.visit login_url, done

  before (done) ->
    browser.fill '#username', 'ehg'
    browser.fill '#password', 'testing'
    browser.pressButton '#login', done

  it 'contains the scraperwiki logo', ->
    h = browser.text('#header h1')
    h.should.equal 'ScraperWiki'

  it 'contains a list of my datasets', ->
    datasets = browser.queryAll('.dataset')
    should.exist datasets
    datasets.length.should.be.above 2


  context 'when I am on the tools page', ->
    before (done) ->
      browser.visit "#{url}/tools", done

    it 'shows the tools I can use to create datasets', ->
      tools = browser.queryAll '.my-tools .tool'
      tools.length.should.be.above 0

    xit 'shows the "Code your own Dataset" tool', ->
      tools = browser.queryAll '.dataset-tools .tool'
      $(tools).text().toLowerCase().should.include 'code your own dataset'
