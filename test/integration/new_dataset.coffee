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
    browser.fill '#username', 'ickletest'
    browser.fill '#password', 'toottoot'
    browser.pressButton '#login', done

  context 'when I click on the newdataset tool', ->
    before (done) ->
        link = browser.query('#tools .newdataset')
        browser.fire 'click', link, ->
          browser.wait done

    it 'takes me to a new dataset page', ->
      result = browser.location.href
      result.should.include "#{url}/dataset/"

    it 'shows me details of how to ssh in to my box', ->
      iframe = browser.query('iframe')
      text = $(iframe).contents().find('body').text()
      text.should.include 'Add your SSH key'
      text.should.include 'ickletest.'
