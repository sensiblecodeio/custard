should = require 'should'
{wd40, browser, login_url, url} = require './helper'

describe 'Home page (not logged in)', ->
  before (done) ->
    browser.get url, done

  before (done) =>
    wd40.getText 'body', (err, text) =>
      @bodyText = text
      done()

  it 'tells me about the platform for data science', =>
    @bodyText.toLowerCase().should.include 'data science'

  it 'gives me a link to sign up for an account', (done) ->
    browser.elementByPartialLinkText 'Sign up', (err, link) ->
      should.exist link
      link.getAttribute 'href', (err, href) ->
        href.should.include '/pricing'
        done()

  it 'tells me about ScraperWiki Data Services', =>
    @bodyText.toLowerCase().should.include 'services'

