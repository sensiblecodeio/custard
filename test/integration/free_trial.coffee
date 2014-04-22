should = require 'should'
{wd40, browser, base_url, login_url, home_url, prepIntegration} = require './helper'

describe 'Free Trial', ->
  prepIntegration()

  context 'when I log in as a free trial user', ->
    before (done) ->
      wd40.fill '#username', 'free-trial-user', ->
        wd40.fill '#password', 'testing', ->
          wd40.click '#login', done

    before (done) ->
      browser.waitForElementByCss '.dataset-list', 4000, done

    it 'should tell me "14 days left"', (done) ->
      wd40.getText '.trial a', (err, text) ->
        text.toLowerCase().should.include '14 days left'
        done()

describe 'Paid user', ->
  prepIntegration()

  context 'when I log in as a paying user', ->
    before (done) ->
      wd40.fill '#username', 'ehg', ->
        wd40.fill '#password', 'testing', ->
          wd40.click '#login', done

    before (done) ->
      browser.waitForElementByCss '.dataset-list', 4000, done

    it 'should not tell me "Free trial"', (done) ->
      wd40.getText 'body', (err, text) ->
        (/Free trial/i.test text).should.be.false
        done()
