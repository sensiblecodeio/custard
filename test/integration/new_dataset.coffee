should = require 'should'
{wd40, browser} = require('../wd40')

url = 'http://localhost:3001'
login_url = "#{url}/login"

describe 'New dataset tool', ->
  before (done) ->
    wd40.init ->
      browser.get login_url, done

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
              done()

      it 'takes me to the dataset settings page', ->
        @currentUrl.should.match new RegExp("#{url}/dataset/[^/]+/settings")

  after (done) ->
    browser.quit ->
      done()
