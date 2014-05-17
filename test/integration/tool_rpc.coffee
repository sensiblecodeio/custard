require './setup_teardown'
should = require 'should'
{wd40, base_url, browser, loginAndGo} = require './helper'

describe 'Tool RPC', ->

  before (done) ->
    loginAndGo 'teststaff', process.env.CU_TEST_STAFF_PASSWORD, "/switch/ehg", done

  context "with a freshly created test app dataset", ->

    before (done) ->
      wd40.click '.new-dataset', ->
        browser.waitForElementByCss '#chooser', 4000, done

    before (done) ->
      wd40.click '.test-app.tool', =>
        browser.waitForElementByCss 'iframe', 7000, =>
          wd40.trueURL (err, url) =>
            @toolURL = url
            @boxID = url.match(/dataset[/]([^/]+)[/]settings/)[1]
            done()

    context 'when the readsettings button is pressed', ->
      before (done) ->
        wd40.switchToBottomFrame ->
          wd40.click '#readsettings', done

      it 'prints the settings', (done) ->
        wd40.getText '#settings', (err, text) =>
          text.should.not.be.empty
          obj = JSON.parse text
          obj.source.apikey.should.be.a.String.and.not.be.empty
          obj.source.url.should.be.a.String.and.match new RegExp @boxID
          obj.source.publishToken.should.be.a.String.and.not.be.empty
          obj.source.box.should.be.a.String.and.equal @boxID
          done()

    context 'when the settings hash is cleared and the readsettings button is pressed again', ->
      before (done) ->
        wd40.click '#clearhash', ->
          wd40.waitForText 'Settings will appear here', done

      before (done) ->
        wd40.switchToBottomFrame ->
          wd40.click '#readsettings', done

      it 'prints the settings', (done) ->
        wd40.getText '#settings', (err, text) =>
          text.should.not.be.empty
          obj = JSON.parse text
          obj.source.apikey.should.be.a.String.and.not.be.empty
          obj.source.url.should.be.a.String.and.match new RegExp @boxID
          obj.source.publishToken.should.be.a.String.and.not.be.empty
          obj.source.box.should.be.a.String.and.equal @boxID
          done()

    context 'when the redirect internal button is pressed', ->
      before (done) ->
        browser.get @toolURL, ->
          wd40.switchToBottomFrame ->
            wd40.click '#redirectInternal', (err, btn) ->
              wd40.switchToTopFrame done

      it 'redirects the host to the specified URL', (done) ->
        regex = new RegExp "^#{base_url}/$"
        wd40.waitForMatchingURL regex, done

    context 'when the redirect external button is pressed', ->
      before (done) ->
        browser.get @toolURL, ->
          wd40.switchToBottomFrame ->
            wd40.click '#redirectExternal', (err, btn) ->
              wd40.switchToTopFrame ->
                setTimeout done, 500

      it 'redirects the host to the specified URL', (done) ->
        wd40.waitForMatchingURL /^http:\/\/www.google.com\/robots.txt$/, done

    context 'when the showURL button is pressed', ->
      before (done) ->
        browser.get @toolURL, ->
          wd40.switchToBottomFrame ->
            wd40.click '#showURL', (err, btn) ->
              wd40.switchToTopFrame done

      before (done) ->
        wd40.switchToBottomFrame done

      it 'shows the scraperwiki.com URL in an element', (done) ->
        wd40.getText '#textURL', (err, text) =>
          text.should.equal @toolURL
          done()

    context 'when the rename button is pressed', ->
      before (done) ->
        browser.get @toolURL, ->
          wd40.switchToBottomFrame ->
            wd40.click '#rename', (err, btn) ->
              wd40.switchToTopFrame done

      it 'renames the dataset', (done) ->
        wd40.waitForText 'Test Dataset (renamed)', done

    context 'when the user details button is pressed', ->
      before (done) ->
        browser.get @toolURL, ->
          wd40.switchToBottomFrame ->
            wd40.click '#getuserdetails', done

      it 'it shows real username', (done) ->
        wd40.waitForText 'real: teststaff', done

      it 'it shows effective username', (done) ->
        wd40.waitForText 'effective: ehg', done

      it 'it shows real display name', (done) ->
        wd40.waitForText 'General Test Testington', done

      it 'it shows effecive display name', (done) ->
        wd40.waitForText 'Chris Blower', done

    context 'when the alert button is pressed', ->
      before (done) ->
        browser.get @toolURL, ->
          wd40.switchToBottomFrame ->
            wd40.click '#alert', done

      it 'shows an alert', (done) ->
        browser.waitForElementByCss '.alert', 4000, done

    context 'when the sql metadata button is pressed', ->
      before (done) ->
        browser.get @toolURL, ->
          wd40.switchToBottomFrame ->
            wd40.click '#sqlmetadata', ->
              browser.waitForElementByCss '#sqlMetaDataText', 4000, done

      it 'displays json', (done) ->
        wd40.getText '#sqlMetaDataText', (err, text) =>
          JSON.parse text
          text.should.not.be.empty
          done()

      it 'returns the correct tables', (done) ->
        wd40.getText '#sqlMetaDataText', (err, text) =>
          obj = JSON.parse text
          should.exist obj?.table?.SurLeTable
          should.exist obj?.table?.VoirLeLapin
          done()

    context 'when the tool sql push button is pressed', ->
      before (done) ->
        wd40.switchToBottomFrame ->
          wd40.click '#sqlpush', ->
            wd40.switchToTopFrame done

      # Wait for tool to be installed
      before (done) ->
        setTimeout done, 5000

      before (done) ->
        wd40.switchToBottomFrame done

      it 'should take me to the test push tool', (done) ->
        wd40.waitForText "Test push tool", done

      it 'should display the correct sql query', (done) ->
        wd40.waitForText "SELECT 1", done

    context 'when I click on "More tools" in the toolbar', ->
      before (done) ->
        browser.get @toolURL, ->
          wd40.switchToTopFrame ->
            browser.waitForElementByCss '#dataset-tools .new-view', 4000, ->
              # we have to scroll the toolbar left, so that we see the "More tools" link
              browser.eval 'document.getElementById("dataset-tools").scrollLeft = 999999', (err, result) ->
                wd40.click '.new-view', (err) ->
                  browser.waitForElementByCss '#chooser .tool', 4000, done

      context 'when I click on the "Test plugin" tool', ->
        before (done) ->
          wd40.click '#chooser .test-plugin.tool', =>
            setTimeout ->
              wd40.switchToBottomFrame ->
                browser.waitForElementByCss '#getDatasetName', 2000, done
            , 4000

        context 'when the "Get dataset name" button is pressed', ->
          before (done) ->
            wd40.switchToBottomFrame ->
              wd40.click '#getDatasetName', done

          it 'shows the parent dataset name', (done) ->
            wd40.getText '#datasetName', (err, text) =>
              text.should.equal "Test Dataset (renamed)"
              done()
