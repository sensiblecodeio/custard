require './setup_teardown'
should = require 'should'
{wd40, browser, home_url, login_url} = require './helper'

describe 'Home page (not logged in)', ->

  before (done) ->
    browser.deleteAllCookies done

  context 'when I visit scraperwiki.com/datasets without logging in', ->

    before (done) ->
      browser.get home_url, done

    it 'I am redirected to the login page', ->
      wd40.trueURL (err, url) ->
        url.should.equal login_url
