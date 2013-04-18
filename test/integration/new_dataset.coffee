should = require 'should'
{wd40, browser, login_url, home_url, prepIntegration} = require './helper'

describe 'New dataset tool', ->
  prepIntegration()

  before (done) ->
    wd40.fill '#username', 'ehg', ->
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
        wd40.click '.newdataset.tool', =>
          browser.waitForElementByTagName 'iframe', 10000, =>
            browser.url (err, url) =>
              @currentUrl = url
              done err

      it 'takes me to the dataset settings page', ->
        @currentUrl.should.match new RegExp("#{home_url}/dataset/[^/]+/settings")

    context 'when I go back to the dataset page', ->
      before (done) ->
        setTimeout done, 5000

      before (done) ->
        browser.get @currentUrl.replace(/\/settings$/, ''), done

      before (done) ->
        browser.waitForElementByPartialLinkText 'Tools', 4000, done

      before (done) ->
        browser.elementByPartialLinkText 'Tools', (err, link) ->
          link.click done

      before (done) ->
        browser.waitForElementByCss '.active', 4000, done

      it 'has the datatables view selected', (done) ->
        browser.elementByCss '.active', (err, link) ->
          link.text (err, text) ->
            text.should.include 'View in a table'
            done()

      it 'has the datatables view installed', (done) ->
        wd40.switchToBottomFrame ->
          wd40.waitForText 'database file does not exist', done
