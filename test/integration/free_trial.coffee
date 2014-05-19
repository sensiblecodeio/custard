require './setup_teardown'
should = require 'should'
{wd40, browser, base_url, loginAndGo} = require './helper'

describe 'Free Trial', ->

  context 'when I log in as a free trial user', ->
    before (done) ->
      loginAndGo 'free-trial-user', 'testing', "/datasets", done

    it 'should tell me "14 days left"', (done) ->
      wd40.getText '.trial a', (err, text) ->
        text.toLowerCase().should.include '14 days left'
        done()

    context 'when I click on the "Free Trial" message', ->
      before (done) ->
        wd40.click '.trial a', done

      it 'should be on the pricing page', (done) ->
        wd40.trueURL (err, url) ->
          url.should.equal "#{base_url}/pricing"
          done()

    context 'when I click the super duper ScraperWiki digger', ->
      before (done) ->
        wd40.click '#logo', done

      it 'should be on the datasets page', (done) ->
        wd40.trueURL (err, url) ->
          url.should.equal "#{base_url}/datasets"
          done()

    context 'when I click the $9 upgrade button', (done) ->
      before (done) ->
        browser.get base_url + '/pricing/expired', ->
          wd40.click '.plan.explorer .upgrade', done

      it 'takes me to the explorer billing details page', (done) ->
        wd40.trueURL (err, url) ->
          url.should.include '/subscribe/medium-ec2'
          done()

      it 'it lets me subscribe without creating a new account', (done) ->
        wd40.elementByCss '#recurly-subscribe', (err, div) ->
          should.exist div
          done()


describe 'Expired Free Trial', ->

  context 'when I log in as an expired free trial user', ->
    before (done) ->
      loginAndGo 'expired-user', 'testing', "/datasets", done

    it 'I am redirected to the pricing page', ->
      wd40.trueURL (err, url) ->
        url.should.equal "#{base_url}/pricing/expired"

    context 'when I click on the "Free Trial" message', ->
      before (done) ->
        wd40.click '.trial a', done

      it 'should be on the pricing expired page', (done) ->
        wd40.trueURL (err, url) ->
          url.should.equal "#{base_url}/pricing/expired"
          done()

    context 'when I click the docs button', (done) ->
      before (done) ->
        wd40.click '.docs a', done

      it 'should be seeing the documentation', (done) ->
        wd40.trueURL (err, url) ->
          url.should.equal "#{base_url}/help"
          done()

    context 'when I click the super duper ScraperWiki digger', ->
      before (done) ->
        wd40.click '#logo', done

      it 'should again be on the pricing expired page', (done) ->
        wd40.trueURL (err, url) ->
          url.should.equal "#{base_url}/pricing/expired"
          done()

    context 'when I click the $9 upgrade button', (done) ->
      before (done) ->
        wd40.click '.plan.explorer .upgrade', done

      it 'takes me to the explorer billing details page', (done) ->
        wd40.trueURL (err, url) ->
          url.should.include '/subscribe/medium-ec2'
          done()

      it 'it lets me subscribe without creating a new account', (done) ->
        wd40.elementByCss '#recurly-subscribe', (err, div) ->
          should.exist div
          done()




describe 'Paid user', ->

  context 'when I log in as a paying user', ->
    before (done) ->
      loginAndGo 'ehg', 'testing', "/datasets", done

    it 'should not tell me "Free trial"', (done) ->
      wd40.getText 'body', (err, text) ->
        (/Free trial/i.test text).should.be.false
        done()

    it 'should not tell me "days left"', (done) ->
      wd40.getText 'body', (err, text) ->
        (/days left/i.test text).should.be.false
        done()

