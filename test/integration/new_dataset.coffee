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

    # Yes I know this will change soon, but I want to make merges easier
    context 'when I go back to the dataset overview page', ->
      before (done) ->
        wd40.waitForText "Untitled dataset", (err) ->
          browser.elementByLinkText "Untitled dataset", (err, link) ->
            link.click done

      it 'has the datatables view installed', (done) ->
        browser.waitForElementByCss '.view', 4000, (err) ->
          browser.elementByCss '.view', (err, view) ->
            view.text (err, text) ->
              text.should.include 'View in a table'
              done err
