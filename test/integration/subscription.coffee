should = require 'should'
{wd40, browser, login_url, home_url, prepIntegration} = require './helper'

describe 'Subscriptions', ->
  prepIntegration()

  before (done) ->
    wd40.fill '#username', 'ehg', ->
      wd40.fill '#password', 'testing', -> wd40.click '#login', done

  context 'when I want to subscribe to the medium plan', ->
    before (done) ->
      browser.get "#{home_url}/subscribe/medium", done

    context 'when I fill in valid details', ->
      before (done) ->
        wd40.fill '.contact_info .first_name input', 'Terry', done
      before (done) ->
        wd40.fill '.contact_info .last_name input', 'Testerson', done
      before (done) ->
        wd40.fill '.contact_info .email input', 'terry@example.org', done
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

      #TODO: wait properly
      before (done) ->
        setTimeout done, 5000

      it 'subscribes me to the plan', (done) ->
        wd40.getText '#info', (err, text) ->
          text.should.include "You've been subscribed to the Explorer plan!"
          done()

      it 'redirects me to the homepage?', (done) ->
        wd40.trueURL (err, url) ->
          url.should.equal "#{home_url}/"
          done()
