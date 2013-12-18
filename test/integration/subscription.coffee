should = require 'should'
{wd40, browser, base_url, login_url, home_url, prepIntegration} = require './helper'

describe 'Subscription Workflow', ->
  prepIntegration()

  before (done) ->
    browser.get base_url + '/pricing', done

  before (done) =>
    wd40.getText 'body', (err, text) =>
      @bodyText = text
      done()

  context 'when I click the "Data Scientist" plan', ->
    before (done) ->
      browser.elementByCssIfExists '.plan.datascientist a', (err, free) ->
        free.click done

    it 'takes me to the sign up page', (done) ->
      wd40.trueURL (err, url) ->
        url.should.include '/signup/datascientist'
        done()

  context 'when I enter my details and click go', ->
    before (done) ->
      wd40.fill '#displayName', 'Tabatha Testington', ->
        # we clear the short name, which has been
        # prefilled with a made up one for us
        wd40.clear '#shortName', ->
          wd40.fill '#shortName', 'tabbytest', ->
            wd40.fill '#email', 'tabby@example.org', ->
              wd40.click '#acceptedTerms', ->
                wd40.click '#go', done

    before (done) ->
      wd40.waitForText 'Order Total', 8000, done

    it 'takes me to the subscription page', (done) ->
      wd40.trueURL (err, url) ->
        url.should.include '/subscribe/'
        done()

  context 'when I fill in valid details', ->
    before (done) ->
      wd40.fill '.billing_info .card_number input', '4111-1111-1111-1111', done
    before (done) ->
      wd40.fill '.billing_info .cvv input', '123', done
    before (done) ->
      wd40.fill '.billing_info .address1 input', 'ScraperWiki Ltd', done
    before (done) ->
      wd40.fill '.billing_info .address2 input', 'Brownlow Hill', done
    before (done) ->
      wd40.fill '.billing_info .city input', 'Liverpool', done
    before (done) ->
      wd40.fill '.billing_info .zip input', 'L3 5RF', done
    before (done) ->
      wd40.fill '.billing_info .state input', 'MERSEYSIDE', done

    before (done) ->
      wd40.click '.submit', done

    it 'it takes me to the /thankyou page', (done) ->
      wd40.waitForMatchingURL /[/]thankyou/, done

    it 'it says thanks', (done) ->
      wd40.waitForText 'Thankyou for signing up', done

    it 'it tells me to check my emails', (done) ->
      wd40.waitForText 'check your email', done
