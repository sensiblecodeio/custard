require './setup_teardown'
should = require 'should'
{wd40, browser, base_url, loginAndGo} = require './helper'
cleaner = require '../cleaner'

describe 'Subscription workflow for new user paying straight away', ->

  before (done) ->
    # TODO(pwaller): Not sure why this is needed, but it interacts with the API
    #                tests otherwise
    # NOTE: It hangs trying to click "Apricot", possibly because it's in the non
    # tial view. But I'm unsure.
    cleaner.clear_and_set_fixtures done

  before (done) ->
    browser.deleteAllCookies done

  before (done) ->
    browser.get base_url + '/pricing', done

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

    # NOTE: we should test recurly integration here (i.e. it actually upgrades there)

    it 'it takes me to the /thankyou page', (done) ->
      wd40.waitForMatchingURL /[/]thankyou/, done

    it 'it says thanks', (done) ->
      wd40.waitForText 'Thankyou for signing up', done

    it 'it tells me to check my emails', (done) ->
      wd40.waitForText 'check your email', done


describe 'Subscription workflow for free trial upgrading', ->

  before (done) ->
    loginAndGo "expired-user", "testing", "/datasets", ->
      wd40.trueURL (err, url) ->
        url.should.include '/pricing/expired'
        done()

  context 'when I click the "Data Scientist" plan', ->
    before (done) ->
      browser.elementByCssIfExists '.plan.datascientist a', (err, free) ->
        free.click done

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

    it 'it does not say expired any more', (done) ->
      wd40.waitForText 'Expired Trialler', =>
        wd40.getText 'body', (err, text) =>
          text = text.toLowerCase()
          text.should.not.match /free\s+trial:\s+expired/
          text.should.not.match /days\s+left/
          done()

    it 'it says go to your datasets', (done) ->
      wd40.waitForText 'Go to your datasets', done



describe 'Editing my subscription', ->

  context 'When I log in as a paying user', ->
    before (done) ->
      loginAndGo "mediummary", "testing", "/datasets", done

    context 'when I click the user menu', ->
      before (done) ->
        wd40.click '#header .dropdown-toggle', done

      it 'there is a link to edit my billing details', (done) ->
        wd40.waitForText "Edit billing details", done

    context 'when I click the billing details link', ->
      before (done) ->
        wd40.click '#header li.billing a', done

      it 'I am redirected to a Recurly account admin page', (done) ->
        wd40.waitForMatchingURL new RegExp("^https://[^.]+[.]recurly[.]com/account"), done
