should = require 'should'
{wd40, browser, login_url, home_url, prepIntegration} = require './helper'

describe 'Home page (not logged in)', ->
  prepIntegration()

  before (done) ->
    browser.deleteAllCookies done

  before (done) ->
    browser.get home_url, done

  before (done) =>
    wd40.getText 'body', (err, text) =>
      @bodyText = text
      done()

  it 'tells me about the platform', =>
    @bodyText.toLowerCase().should.include 'platform'

  it 'tells me about code in your browser tool', =>
    @bodyText.toLowerCase().should.include 'code in your browser'

  it 'gives me a link to sign up for an account', (done) ->
    browser.elementByPartialLinkText 'Sign up', (err, link) ->
      should.exist link
      link.getAttribute 'href', (err, href) ->
        href.should.include '/pricing'
        done()
