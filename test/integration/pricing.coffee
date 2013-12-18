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

    it 'it lets me sign up to a free "Community" plan', (done) ->
      wd40.elementByCss '.plan.community .cta', (err, element) ->
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

    it 'it lets me sign up to a $199 "Enterprise" plan', (done) ->
      wd40.elementByCss '.plan.enterprise .cta', (err, element) ->
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

    it 'it shows that the community plan is my current plan', (done) ->
      wd40.elementByCss '.plan.community .currentPlan', (err, element) ->
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

    it 'it lets me upgrade to the $199 plan', (done) ->
      wd40.elementByCss '.plan.enterprise .upgrade', (err, element) ->
        should.exist element
        element.text (err, text) ->
          text.should.match /upgrade/i
          done()

    context 'when I click the $29 upgrade button', (done) ->
      before (done) ->
        wd40.click '.plan.datascientist .upgrade', done

      it 'takes me to the data scientist billing details page', (done) ->
        wd40.trueURL (err, url) ->
          url.should.include '/subscribe/large-ec2'
          done()

    context 'when I click the $199 upgrade button', (done) ->
      before (done) ->
        browser.get base_url + '/pricing', done

      before (done) ->
        wd40.click '.plan.enterprise .upgrade', done

      it 'takes me to the enterprise billing details page', (done) ->
        wd40.trueURL (err, url) ->
          url.should.include '/subscribe/xlarge-ec2'
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

    it 'it tells me to contact ScraperWiki for a downgrade', (done) ->
      wd40.getText '.plan.community', (err, text) ->
        text.should.match /contact to downgrade/i
        done()

    it 'it lets me upgrade to the $199 plan', (done) ->
      wd40.elementByCss '.plan.enterprise .upgrade', (err, element) ->
        should.exist element
        element.text (err, text) ->
          text.should.match /upgrade/i
          done()

    context 'when I click the $199 upgrade button', (done) ->
      before (done) ->
        wd40.click '.plan.enterprise .upgrade', done

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

        it 'it shows I am on the $199 plan', (done) ->
          wd40.elementByCss '.plan.enterprise .currentPlan', (err, element) ->
            should.exist element
            element.text (err, text) ->
              text.should.match /current plan/i
              done()

        it 'it lets me downgrade to the $29 plan', (done) ->
          wd40.elementByCss '.plan.datascientist .downgrade-now', (err, element) ->
            should.exist element
            element.text (err, text) ->
              text.should.match /downgrade/i
              done()

        context 'when I click the $29 downgrade button', (done) ->
          before (done) ->
            wd40.click '.plan.datascientist .downgrade-now', done

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

            it 'it shows I am on the $29 plan', (done) ->
              wd40.elementByCss '.plan.datascientist .currentPlan', (err, element) ->
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

    it 'none of the plans are shown to be my current plan', (done) ->
      browser.elementByCss '.currentPlan', (err, element) ->
        should.not.exist element
        done()

    it 'it lets me upgrade to the $29 plan', (done) ->
      wd40.elementByCss '.plan.datascientist .upgrade', (err, element) ->
        should.exist element
        element.text (err, text) ->
          text.should.match /upgrade/i
          done()

    it 'it lets me upgrade to the $199 plan', (done) ->
      wd40.elementByCss '.plan.enterprise .upgrade', (err, element) ->
        should.exist element
        element.text (err, text) ->
          text.should.match /upgrade/i
          done()

    it 'it tells me to contact ScraperWiki for a downgrade', (done) ->
      wd40.getText '.plan.community', (err, text) ->
        text.should.match /contact to downgrade/i
        done()
