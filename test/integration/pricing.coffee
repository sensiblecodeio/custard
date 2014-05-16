require './setup_teardown'
should = require 'should'
{wd40, browser, base_url, login_url, home_url, prepIntegration, mediumizeMary, enlargeLucy} = require './helper'

describe 'Pricing', ->
  prepIntegration()

  context 'When I visit the pricing page (as a non-customer)', ->
    before (done) ->
      browser.get base_url + '/pricing', done

    it 'has "Pricing" in the page title', (done) ->
      browser.title (err, title) ->
        title.should.match /Pricing/g
        done()

    it 'it lets me sign up to a "Free Trial" plan', (done) ->
      wd40.elementByCss '.plan.freetrial .cta', (err, element) ->
        should.exist element
        element.text (err, text) ->
          text.should.match /sign up/i
          done()

    it 'it lets me sign up to a $9 "Explorer" plan', (done) ->
      wd40.elementByCss '.plan.explorer .cta', (err, element) ->
        should.exist element
        element.text (err, text) ->
          text.should.match /sign up/i
          done()

    it 'it lets me sign up to a $29 "Data Scientist" plan', (done) ->
      wd40.elementByCss '.plan.datascientist .cta', (err, element) ->
        should.exist element
        element.text (err, text) ->
          text.should.match /sign up/i
          done()

    context 'when I click the "datascientist" plan', ->
      before (done) ->
        wd40.click '.plan.datascientist a', done

      it 'takes me to the sign up page', (done) ->
        wd40.trueURL (err, url) ->
          url.should.include '/signup/datascientist'
          done()

  context 'When I visit the pricing page (as a free user)', ->
    before (done) ->
      browser.get login_url, ->
        wd40.fill '#username', 'ickletest', ->
          wd40.fill '#password', 'toottoot', ->
            wd40.click '#login', done

    before (done) ->
      browser.get base_url + '/pricing', done

    it 'it shows that the free trial plan is my current plan', (done) ->
      wd40.elementByCss '.plan.freetrial .currentPlan', (err, element) ->
        should.exist element
        element.text (err, text) ->
          text.should.match /current plan/i
          done()

    it 'it lets me upgrade to the $9 plan', (done) ->
      wd40.elementByCss '.plan.explorer .upgrade', (err, element) ->
        should.exist element
        element.text (err, text) ->
          text.should.match /upgrade/i
          done()

    it 'it lets me upgrade to the $29 plan', (done) ->
      wd40.elementByCss '.plan.datascientist .upgrade', (err, element) ->
        should.exist element
        element.text (err, text) ->
          text.should.match /upgrade/i
          done()

    context 'when I click the $9 upgrade button', (done) ->
      before (done) ->
        browser.get base_url + '/pricing', ->
          wd40.click '.plan.explorer .upgrade', done

      it 'takes me to the explorer billing details page', (done) ->
        wd40.trueURL (err, url) ->
          url.should.include '/subscribe/medium-ec2'
          done()

      it 'it lets me subscribe without creating a new account', (done) ->
        wd40.elementByCss '#recurly-subscribe', (err, div) ->
          should.exist div
          done()


    context 'when I click the $29 upgrade button', (done) ->
      before (done) ->
        browser.get base_url + '/pricing', ->
          wd40.click '.plan.datascientist .upgrade', done

      it 'takes me to the data scientist billing details page', (done) ->
        wd40.trueURL (err, url) ->
          url.should.include '/subscribe/large-ec2'
          done()

      it 'it lets me subscribe without creating a new account', (done) ->
        wd40.elementByCss '#recurly-subscribe', (err, div) ->
          should.exist div
          done()


    after (done) ->
      browser.get "#{base_url}/logout", done

  context 'When I visit the pricing page (as a $29 user)', ->
    before (done) ->
      browser.get login_url, ->
        wd40.fill '#username', 'largelucy', ->
          wd40.fill '#password', 'testing', ->
            wd40.click '#login', done

    before (done) ->
      browser.get base_url + '/pricing', done

    it 'it shows that the data scientist plan is my current plan', (done) ->
      wd40.elementByCss '.plan.datascientist .currentPlan', (err, element) ->
        should.exist element
        element.text (err, text) ->
          text.should.match /current plan/i
          done()

    it 'it tells me to contact ScraperWiki for a downgrade to free trial', (done) ->
      wd40.getText '.plan.freetrial', (err, text) ->
        text.should.match /contact to downgrade/i
        done()

    it 'it lets me downgrade to the $9 explorer plan', (done) ->
      wd40.elementByCss '.plan.explorer .downgrade-now', (err, element) ->
        should.exist element
        element.text (err, text) ->
          text.should.match /downgrade/i
          done()

    context 'when I click the $9 downgrade button', (done) ->
      before (done) ->
        enlargeLucy done

      before (done) ->
        wd40.click '.plan.explorer .downgrade-now', done

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
          setTimeout ->
            wd40.waitForInvisibleByCss '.modal', done
          , 2000

        it 'it shows I am on the $9 plan', (done) ->
          wd40.elementByCss '.plan.explorer .currentPlan', (err, element) ->
            should.exist element
            element.text (err, text) ->
              text.should.match /current plan/i
              done()

    after (done) ->
      browser.get "#{base_url}/logout", done

  context 'When I visit the pricing page (as a $9 user)', ->
    before (done) ->
      browser.get login_url, ->
        wd40.fill '#username', 'mediummary', ->
          wd40.fill '#password', 'testing', ->
            wd40.click '#login', done

    before (done) ->
      browser.get base_url + '/pricing', done

    before (done) ->
      browser.waitForElementByCss '.plan', 4000, done

    it 'it shows that the explorer plan is my current plan', (done) ->
      wd40.elementByCss '.plan.explorer .currentPlan', (err, element) ->
        should.exist element
        element.text (err, text) ->
          text.should.match /current plan/i
          done()

    it 'it lets me upgrade to the $29 plan', (done) ->
      wd40.elementByCss '.plan.datascientist .upgrade', (err, element) ->
        should.exist element
        element.text (err, text) ->
          text.should.match /upgrade/i
          done()

    context 'when I click the $29 upgrade button', (done) ->
      before (done) ->
        mediumizeMary done

      before (done) ->
        wd40.click '.plan.datascientist .upgrade', done

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
          setTimeout ->
            wd40.waitForInvisibleByCss '.modal', done
          , 2000

        it 'it shows I am on the $29 plan', (done) ->
          wd40.elementByCss '.plan.datascientist .currentPlan', (err, element) ->
            should.exist element
            element.text (err, text) ->
              text.should.match /current plan/i
              done()

    it 'it tells me to contact ScraperWiki for a downgrade', (done) ->
      wd40.getText '.plan.freetrial', (err, text) ->
        text.should.match /contact to downgrade/i
        done()

  context 'When I visit the pricing upgrade page', ->
    before (done) ->
      browser.get base_url + '/pricing/upgrade', done

    it 'it implores me to upgrade to create more datasets', (done) ->
      wd40.elementByCss '.pricing .alert', (err, element) ->
        should.exist element
        element.text (err, text) ->
          text.should.match /Please upgrade your account/i
          text.should.match /to create more datasets/i
          done()

  context 'When I visit the pricing expired page', ->
    before (done) ->
      browser.get base_url + '/pricing/expired', done

    it 'it implores me to upgrade since my trial has ended', (done) ->
      wd40.elementByCss '.pricing .alert', (err, element) ->
        should.exist element
        element.text (err, text) ->
          text.should.match /Please upgrade your account/i
          text.should.match /your free trial has ended/i
          done()

  context 'When I visit the pricing large PDFs page', ->
    before (done) ->
      browser.get base_url + '/pricing/largepdf', done

    it 'it implores me to upgrade to process large PDFs', (done) ->
      wd40.elementByCss '.pricing .alert', (err, element) ->
        should.exist element
        element.text (err, text) ->
          text.should.match /Please upgrade your account/i
          text.should.match /to be able to process large PDFs/i
          done()


