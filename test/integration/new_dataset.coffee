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
        link = browser.query('.newdataset.tool')
        browser.fire 'click', link, ->
          browser.wait done

      it 'takes me to the dataset settings page', ->
        result = browser.location.href
        result.should.match new RegExp("#{url}/dataset/[^/]+/settings")
