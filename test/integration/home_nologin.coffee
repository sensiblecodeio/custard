should = require 'should'
{wd40, browser, base_url, login_url, home_url, prepIntegration} = require './helper'

describe 'Home page (not logged in)', ->
  prepIntegration()

  before (done) ->
    browser.deleteAllCookies done

  context 'when I visit scraperwiki.com/datasets without logging in', ->

  before (done) ->
    browser.get home_url, done

  it 'I am redirected to the login page', ->
    wd40.trueURL (err, url) ->
      url.should.equal login_url
