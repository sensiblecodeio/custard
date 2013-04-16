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
      # TODO: we shouldn't need to wait
      # wait a while for the data tables view to be created(!)
      before (done) ->
        setTimeout done, 4000

      before (done) ->
        wd40.waitForText "Untitled dataset", (err) ->
          browser.elementByLinkText "Untitled dataset", (err, link) ->
            link.click done

      it 'has the datatables view installed', (done) ->
        wd40.switchToBottomFrame ->
          wd40.waitForText 'database file does not exist', done
