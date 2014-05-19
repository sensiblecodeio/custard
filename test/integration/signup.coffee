require './setup_teardown'
should = require 'should'
{wd40, browser, base_url, home_url} = require './helper'

describe 'Sign up', ->

  before (done) ->
    browser.deleteAllCookies done

  context 'when I select the Free plan on the pricing page', ->
    before (done) ->
      browser.get "#{base_url}/pricing/", done

    before (done) ->
      wd40.click '.plan.freetrial a', done

    it 'has "Free Trial" and "Sign Up" in the page title', (done) ->
      browser.title (err, title) ->
        title.should.match /Free Trial/g
        title.should.match /Sign Up/g
        done()

    it 'the newsletter checkbox is ticked by default', (done) ->
      wd40.elementByCss '#emailMarketing', (err, element) ->
        should.exist element
        element.getAttribute 'checked', (err, checked) ->
          should.exist checked
          checked.should.be.ok # asserts truthfulness
          done()

    context 'when I enter my details and click go', ->
      before (done) ->
        wd40.fill '#displayName', 'Tabatha Testington', ->
          # we clear the short name, which has been prefilled with a made up one for us
          # XXX test the text of the prefilled one is good
          wd40.clear '#shortName', ->
            wd40.fill '#shortName', 'tabbytest', ->
              wd40.fill '#email', 'tabby@example.org', ->
                wd40.click '#acceptedTerms', ->
                  wd40.click '#go', done

      it 'it says thanks', (done) ->
        wd40.waitForText 'Thankyou for signing up', 10000, done

      it 'it tells me to check my emails', (done) ->
        wd40.waitForText 'check your email', done

      it 'it takes me to the /thankyou page', (done) ->
        wd40.waitForMatchingURL /[/]thankyou/, done

