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

    context 'when I click on the highrise tool', ->
      before (done) ->
        link = browser.query('.tool a[href="/tool/highrise"]')
        browser.fire 'click', link, done

      it 'takes me to the highrise tool page', ->
        result = browser.location.href
        result.should.equal "#{url}/tool/highrise"

      it 'displays the setup message of the tool', (done) ->
        browser.wait ->
          browser.text().should.include "Enter your username and password"
          done()


      context 'when I enter my details and click import', ->
        before (done) ->
          browser.fill '#username', process.env.HIGHRISE_USER
          browser.fill '#password', process.env.HIGHRISE_PASSWORD
          browser.fill '#domain', process.env.HIGHRISE_DOMAIN
          browser.pressButton  '#import', ->
            browser.wait done

        it 'shows a lovely spreadsheet of our amazing data', ->
          browser.location.href.should.include "#{url}/dataset/"

        it 'has made a JSON cookie', ->
          result = browser.evaluate "function(){return $.cookie('datasets')}"
          parsed = JSON.parse result
          should.exist parsed

