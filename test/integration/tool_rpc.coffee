# See custard/README.md for Selenium setup instructions

should = require 'should'
{wd40, browser} = require('../wd40')

BASE_URL = 'http://localhost:3001' # DRY DRY DRY
login_url = "#{BASE_URL}/login"


describe 'Tool RPC', ->
  before (done) ->
    wd40.init done

  before (done) ->
    browser.get login_url, ->
      wd40.fill '#username', 'ehg', ->
        wd40.fill '#password', 'testing', ->
          wd40.click '#login', done

  context "with a freshly created test app dataset", ->
    before (done) ->
      browser.waitForElementByCss '.dataset-list', 4000, done

    before (done) ->
      wd40.click '.new-dataset', ->
        browser.waitForElementByCss '#chooser', 4000, done

    before (done) ->
      wd40.click '.test-app.tool', =>
        browser.waitForElementByCss 'iframe', 4000, =>
          wd40.trueURL (err, url) =>
            @toolURL = url
            done()

    context 'when the redirect internal button is pressed', ->
      before (done) ->
        wd40.switchToBottomFrame ->
          wd40.click '#redirectInternal', (err, btn) ->
            wd40.switchToTopFrame done

      it 'redirects the host to the specified URL', (done) ->
        wd40.trueURL (err, url) ->
          url.should.equal "#{BASE_URL}/"
          done()

    context 'when the redirect external button is pressed', ->
      before (done) ->
        browser.get @toolURL, ->
          wd40.switchToBottomFrame ->
            wd40.click '#redirectExternal', (err, btn) ->
              wd40.switchToTopFrame done

      it 'redirects the host to the specified URL', (done) ->
        wd40.trueURL (err, url) ->
          url.should.equal 'http://www.google.com/robots.txt'
          done()

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

  after (done) ->
    browser.quit ->
      done()
