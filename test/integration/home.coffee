Browser = require 'zombie'
should = require 'should'

url = 'http://localhost:3000'
login_url = "#{url}/login"

describe 'Home page (logged in)', ->
  browser = new Browser()

  before (done) ->
    browser.visit login_url, done

  before (done) ->
    browser.fill '#username', 'ickletest'
    browser.fill '#password', 'toottoot'
    browser.pressButton '#login', done

  it 'contains the scraperwiki logo', ->
    h = browser.text('#header h1')
    h.should.equal 'Logo'


  it 'contains a list of my datasets', ->
    datasets = browser.queryAll('#datasets div')
    should.exist datasets
    datasets.length.should.be.above 0

  context 'when I click on the highrise tool', ->
    before (done) ->
      link = browser.query('#tools .highrise')
      browser.fire 'click', link, done

    it 'takes me to the highrise tool page', ->
      result = browser.location.href
      result.should.equal "#{url}/tool/highrise"

    xit 'shows the tool is loading', ->
      should.exist browser.query('p.loading')

    it 'displays the setup message of the tool', (done) ->
      browser.wait ->
        browser.text().match(/Enter your username and password/) is true
        done()

    context 'when I enter my details and click import', ->
      before (done) ->
        browser.fill '#username', process.env.HIGHRISE_USER
        browser.fill '#password', process.env.HIGHRISE_PASSWORD
        browser.fill '#domain', process.env.HIGHRISE_DOMAIN
        browser.pressButton  '#import', ->
          done()

      it 'shows a lovely spreadsheet of our amazing data', (done) ->
        forImport = (window, wut) ->
          window.document.querySelector('iframe')?

        browser.wait forImport, (err, browser2) ->
          browser.html('#content').should.include 'spreadsheet-tool'
          done()

      it 'has now a crontab'

      it 'has made a JSON cookie', ->
        result = browser.evaluate "function(){return $.cookie('datasets')}"
        parsed = JSON.parse result
        should.exist parsed

        context 'when I visit the homepage', ->

          it 'shows my previous dataset'

