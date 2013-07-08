should = require 'should'
{wd40, browser, login_url, home_url, prepIntegration} = require './helper'

describe 'Upgrade from free account to paid', ->
  prepIntegration()


  before (done) ->
    wd40.fill '#username', 'ickletest', ->
      wd40.fill '#password', 'toottoot', -> wd40.click '#login', done

  context 'when I go to the pricing page', ->
    before (done) ->
      browser.get "#{home_url}/pricing/", done
      
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