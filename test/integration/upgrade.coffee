should = require 'should'
{wd40, browser, base_url, login_url, home_url, prepIntegration, mediumizeMary} = require './helper'

describe 'Upgrade from free account to paid', ->
  prepIntegration()

  before (done) ->
    wd40.fill '#username', 'ickletest', ->
      wd40.fill '#password', 'toottoot', ->
        wd40.click '#login', done

  context 'when I go to the pricing page', ->
    before (done) ->
      browser.get "#{base_url}/pricing/", done

    it 'it shows I am on the free community plan', (done) ->
      wd40.elementByCss '.account-free .currentPlan', (err, span) ->
        should.exist span
        done()

    it 'it shows I can upgrade to the medium plan', (done) ->
      wd40.elementByCss '.account-medium .cta', (err, span) ->
        span.text (err, text) ->
          text.should.include 'Upgrade'
          done()

    it 'it shows I can upgrade to the large plan', (done) ->
      wd40.elementByCss '.account-large .cta', (err, span) ->
        span.text (err, text) ->
          text.should.include 'Upgrade'
          done()

    context 'when I click on the medium upgrade button', ->
      before (done) ->
        wd40.click '.account-medium a', done

      it 'it lets me subscribe without creating a new account', (done) ->
        wd40.elementByCss '#recurly-subscribe', (err, div) ->
          should.exist div
          done()

describe 'Upgrade from medium account to large account', ->
  prepIntegration()

  before (done) ->
    mediumizeMary done

  before (done) ->
    wd40.fill '#username', 'mediummary', ->
      wd40.fill '#password', 'testing', ->
        wd40.click '#login', done

  context 'when I go to the pricing page', ->
    before (done) ->
      browser.get "#{base_url}/pricing/", done

    it 'it shows I am on the medium plan', (done) ->
      wd40.elementByCss '.account-medium .currentPlan', (err, span) ->
        should.exist span
        done()

    it 'it shows I can upgrade to the large plan', (done) ->
      wd40.elementByCss '.account-large .cta', (err, span) ->
        span.text (err, text) ->
          text.should.include 'Upgrade'
          done()

    context 'when I click on the large upgrade button', ->
      before (done) ->
        wd40.click '.account-large a', done

      it 'it opens a modal window checking I\'m sure', (done) ->
        wd40.elementByCss '.modal', (err, modal) ->
          should.exist modal
          done()

      context 'when I click the only button on the modal', ->
        # wait a little while for the modal fade effect to finish
        before (done) ->
          setTimeout done, 500

        before (done) ->
          wd40.click '.modal .btn', done

        it 'it closes the modal window', (done) ->
          wd40.waitForInvisibleByCss '.modal', done

        it 'it shows I am on the large plan', (done) ->
          wd40.elementByCss '.account-large .currentPlan', (err, span) ->
            should.exist span
            done()

    context 'when I downgrade again', ->
      before (done) ->
        wd40.click '.account-medium a', done

      it 'it opens a modal window checking I\'m sure', (done) ->
        wd40.elementByCss '.modal', (err, modal) ->
          should.exist modal
          done()

      context 'when I click the only button on the modal', ->
        # wait a little while for the modal fade effect to finish
        before (done) ->
          setTimeout done, 500

        before (done) ->
          wd40.click '.modal .btn', done

        it 'it closes the modal window', (done) ->
          wd40.waitForInvisibleByCss '.modal', done

        it 'it shows I am on the medium plan', (done) ->
          wd40.elementByCss '.account-medium .currentPlan', (err, span) ->
            should.exist span
            done()
