should = require 'should'
{wd40, browser, base_url, login_url, home_url, prepIntegration} = require './helper'

describe '3 dataset limit for free users', ->
  prepIntegration()

  before (done) ->
    wd40.fill '#username', 'mrgreedy', ->
      wd40.fill '#password', 'testing', ->
        wd40.click '#login', done

  before (done) ->
    browser.waitForElementByCss '.dataset-list', 4000, done

  context 'when I click the "new dataset" button', ->
    before (done) ->
      wd40.click '.new-dataset', ->
        browser.waitForElementByCss '#chooser .tool', 4000, done

    context 'when I click on the newdataset tool', ->
      before (done) ->
        wd40.click '.newdataset.tool', ->
          browser.waitForElementByCss '.pricing', 4000, done

      it 'is on the pricing page', (done) ->
        browser.url (err, url) ->
          url.should.include '/pricing'
          done()

      it 'shows me an upgrade message', (done) ->
        wd40.getText 'body', (err, text) ->
          text.toLowerCase().should.include 'please upgrade'
          done()
