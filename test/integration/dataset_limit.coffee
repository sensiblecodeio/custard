require './setup_teardown'
should = require 'should'
{wd40, browser, loginAndGo} = require './helper'

describe '3 dataset limit for free users', ->

  before (done) ->
    loginAndGo "mrgreedy", "testing", "/datasets", done

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
