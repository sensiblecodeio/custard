require './setup_teardown'
should = require 'should'
{wd40, browser, base_url, loginAndGo} = require './helper'

describe 'New dataset tool', ->

  it "goes to ehg's /datasets", (done) ->
    loginAndGo 'ehg', 'testing', "/datasets", done

  context 'when I click the "new dataset" button', ->
    iframeUrl = null
    it 'waits for the tool chooser', (done) ->
      wd40.click '.new-dataset', ->
        browser.waitForElementByCss '#chooser .tool', 4000, done

    context 'when I click on the newdataset tool', ->
      it "clicks the newdataset tool", (done) ->
        wd40.click '.newdataset.tool', =>
          browser.waitForElementByTagName 'iframe', 10000, =>
            browser.url (err, url) =>
              @currentUrl = url
              done err

      it 'waits for the tool menu toggle to load', (done) ->
        # wait for the tool menu toggle to load
        setTimeout done, 1000

      it 'takes me to the dataset settings page', ->
        @currentUrl.should.match new RegExp("#{base_url}/dataset/[^/]+/settings")

      it 'and shows that the "Code a dataset" tool is active', (done) ->
        wd40.elementByCss '#toolbar .active', (err, link) ->
          link.text (err, text) ->
            text.toLowerCase().replace('\n',' ').should.include 'code a dataset'
            done()

      it 'and shows me the "Code in a dataset" tool contents', (done) ->
        wd40.switchToBottomFrame ->
          wd40.trueURL (err, url) ->
            iframeUrl = url
            done()

    context 'when I wait a little while and then go back to the dataset page', ->
      it 'waits for the tool to be installed in the background', (done) ->
        # wait for the data tables tool to be installed in the background
        setTimeout done, 5000

      it 'goes to /settings', (done) ->
        browser.get @currentUrl.replace(/\/settings$/, ''), done

      it 'shows that the "View in a table" tool is active', (done) ->
        wd40.elementByCss '#toolbar .active', (err, link) ->
          link.text (err, text) ->
            text.toLowerCase().replace('\n',' ').should.include 'view in a table'
            done()

      it 'and shows me the "View in a table" tool contents', (done) ->
        wd40.switchToBottomFrame ->
          wd40.trueURL (err, url) ->
            url.should.not.equal iframeUrl
            done()
