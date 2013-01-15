$ = jQuery = require 'jquery'
Browser = require 'zombie'
should = require 'should'

url = 'http://localhost:3001' # DRY DRY DRY
login_url = "#{url}/login"

describe 'New dataset tool', ->
  browser = new Browser()
  browser.waitDuration = "10s"

  before (done) ->
    browser.visit login_url, done

  before (done) ->
    browser.fill '#username', 'ehg'
    browser.fill '#password', 'testing'
    browser.pressButton '#login', done

  context 'when I am on the tools page', ->
    before (done) ->
      browser.visit "#{url}/tools", done

    context 'when I click on the newdataset tool', ->
      before (done) ->
        link = browser.query('a[href="/tool/newdataset"].tool')
        browser.fire 'click', link, ->
          browser.wait done

      it 'takes me to the new dataset page', ->
        result = browser.location.href
        result.should.include "#{url}/dataset/"

      context 'when I click on the view source view', ->
        before (done) ->
          link = browser.query('.newdataset a')
          browser.fire 'click', link, ->
            browser.wait 1000, ->
              browser.wait done

        xit 'takes me to the view source view', ->
          result = browser.location.href
          result.should.include '/newdataset'

        xit 'shows me details of how to ssh in to my box', ->
          iframe = browser.query('iframe')
          text = $(iframe).contents().find('body').text()
          text.should.include 'Add your SSH key'
          text.should.match /\w+@box\.scraperwiki\.com/g
