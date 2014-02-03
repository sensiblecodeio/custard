should = require 'should'
{wd40, browser, base_url, login_url, home_url, prepIntegration} = require './helper'

describe 'Password reset', ->
  prepIntegration()

  context 'when I forget my password on the Log In page', ->
    before (done) ->
      browser.get login_url, done

    it 'there is a link to reset my password', (done) ->
      wd40.elementByCss 'a[href$="/set-password/"]', done

    context 'when I click the link', ->
      before (done) ->
        wd40.click 'a[href$="/set-password/"]', done

      it 'it takes me to the /set-password page', (done) ->
        wd40.waitForMatchingURL /[/]set-password/, done

      it 'it gives me a link to click if I have forgotten my username', (done) ->
        browser.waitForElementByCss '#forgotten-shortname', 4000, done

      context 'when I enter an incorrect username', ->
        before (done) ->
          wd40.fill '#shortname', 'i-do-not-exist', ->
            wd40.click '#go', done

        it 'it shows me that the username was wrong', (done) ->
          wd40.waitForText 'That username could not be found', done

      context 'when I enter a correct username', ->
        before (done) ->
          browser.get "#{base_url}/set-password/", ->
            browser.waitForElementByCss '#shortname', 4000, done

        before (done) ->
          wd40.fill '#shortname', 'ickletest', ->
            wd40.click '#go', done

        it 'it tells me to check my emails', (done) ->
          wd40.waitForText 'check your email', done

      context 'when I cause some sort of weird error', ->
        before (done) ->
          browser.get "#{base_url}/set-password/", ->
            browser.waitForElementByCss '#shortname', 4000, done

        before (done) ->
          wd40.fill '#shortname', 'ehg', ->
            wd40.click '#go', done

        it 'it tells me something unexpected went wrong', (done) ->
          wd40.waitForText 'Something went wrong', done

        it 'it tells me to email hello@scraperwiki.com', (done) ->
          wd40.waitForText 'hello@scraperwiki.com', done
