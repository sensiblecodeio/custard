should = require 'should'
{wd40, browser, base_url, login_url, home_url, prepIntegration} = require './helper'

describe 'Pricing', ->
  prepIntegration()

  context 'When I visit the pricing page (as a non-customer)', ->
    before (done) ->
      browser.get base_url + '/pricing', done

    before (done) =>
      wd40.getText 'body', (err, text) =>
        @bodyText = text
        done()

    it 'has "Pricing" in the page title', (done) ->
      browser.title (err, title) ->
        title.should.match /Pricing/g
        done()

    it 'shows me a free "community" plan', =>
      @bodyText.toLowerCase().should.include 'community'

    it 'shows me an expensive "data scientist" plan', =>
      @bodyText.toLowerCase().should.include 'data scientist'

    context 'when I click the "datascientist" plan', ->
      before (done) ->
        wd40.click '.plan.datascientist a', done

      it 'takes me to the sign up page', (done) ->
        wd40.trueURL (err, url) ->
          url.should.include '/signup/datascientist'
          done()

  context 'When I visit the pricing page (as an existing customer)', ->
    before (done) ->
      browser.get login_url, ->
        # user details from fixtures.js
        wd40.fill '#username', 'ickletest', ->
          wd40.fill '#password', 'toottoot', ->
            wd40.click '#login', done

    before (done) ->
      browser.get base_url + '/pricing', done

    it 'it shows my current pricing plan', (done) ->
      wd40.elementByPartialLinkText 'Current Plan', (err, link) ->
        should.exist link
        done()
