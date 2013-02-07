wd = require 'wd'
should = require 'should'

browser = wd.remote()
wd40 = require('../wd40')(browser)

url = 'http://localhost:3001'
login_url = "#{url}/login"

describe 'Home page (logged in)', ->
  before (done) ->
    wd40.init ->
      browser.get login_url, done

  before (done) ->
    wd40.fill '#username', 'ehg', ->
      wd40.fill '#password', 'testing', ->
        wd40.click '#login', done

  before (done) ->
    browser.waitForElementByCss '#userlinks', 4000, done

  it 'contains the scraperwiki logo', (done) ->
    wd40.getText '#header h1', (err, h) ->
      h.should.equal 'ScraperWiki'
      done()

  it 'contains a list of my datasets', (done) ->
    browser.waitForVisibleByCss '.dataset', 4000, ->
      browser.elementsByCss '.dataset', (err, datasets) ->
        should.exist datasets
        datasets.length.should.be.above 2
        done()

  context 'when I am on the tools page', ->
    before (done) ->
      browser.get "#{url}/tools", done

    it 'shows the tools I can use to create datasets', (done) ->
      browser.waitForVisibleByCss '.my-tools .tool', 4000, ->
        browser.elementsByCss '.my-tools .tool', (err, tools) ->
          tools.length.should.be.above 0
          done()

  after (done) ->
    browser.quit ->
      done()
