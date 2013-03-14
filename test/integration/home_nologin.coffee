wd = require 'wd'
should = require 'should'

browser = wd.remote()
wd40 = require('../wd40')(browser)

url = 'http://localhost:3001'

describe 'Home page (not logged in)', ->
  before (done) ->
    wd40.init ->
      browser.get url, done

  before (done) =>
    wd40.getText 'body', (err, text) =>
      @bodyText = text
      done()

  it 'tells me about the platform for data science', =>
    @bodyText.toLowerCase().should.include 'platform for data science'

  it 'gives me a link to sign up for an account', (done) ->
    browser.elementByPartialLinkText 'Sign up', (err, link) ->
      should.exist link
      link.getAttribute 'href', (err, href) ->
        href.should.include '/pricing'
        done()

  it 'tells me about ScraperWiki Data Services', =>
    @bodyText.toLowerCase().should.include 'scraperwiki data services'

  it 'tells me about the people pack', =>
    @bodyText.toLowerCase().should.include 'people pack'
