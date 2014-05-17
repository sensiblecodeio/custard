require './setup_teardown'
should = require 'should'
{wd40, browser, base_url, home_url, loginAndGo} = require './helper'

request = require 'request'

describe 'Login after introduction of Terms & Conditions', ->

  context 'when I log in after a long time away', ->

    before (done) ->
      browser.deleteAllCookies done

    before (done) ->
      loginAndGo "mrlazy", "testing", "/datasets", done

    it 'an alert bar asks me to agree to the new terms & conditions', (done) ->
      wd40.getText 'body', (err, text) ->
        text.toLowerCase().should.include 'terms & conditions have changed'
        done()

    context 'when I click the "I accept" button', ->
      before (done) ->
        wd40.click '#acceptTerms', ->
          setTimeout done, 1000

      it 'the message goes away', (done) ->
        wd40.getText 'body', (err, text) ->
          text.toLowerCase().should.not.include 'terms & conditions have changed'
          done()

      context 'and when I revist the homepage', ->
        before (done) ->
          browser.get home_url, done

        it 'the message is not show again', (done) ->
          wd40.getText 'body', (err, text) ->
            text.toLowerCase().should.not.include 'terms & conditions have changed'
            done()
