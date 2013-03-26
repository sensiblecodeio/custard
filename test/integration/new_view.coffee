should = require 'should'
{wd40, browser} = require('../wd40')

url = 'http://localhost:3001'
login_url = "#{url}/login"

describe 'New view tool', ->
  before (done) ->
    wd40.init ->
      browser.get login_url, done

  before (done) ->
    wd40.fill '#username', 'ehg', ->
      wd40.fill '#password', 'testing', ->
        wd40.click '#login', done

  context 'when I click on an Apricot dataset', ->
    before (done) ->
      # wait for tiles to fade in
      setTimeout ->
        browser.elementByPartialLinkText 'Apricot', (err, link) ->
          link.click done
      , 500

    it 'takes me to the Apricot dataset page', (done) ->
      wd40.trueURL (err, result) ->
        result.should.match /\/dataset\/(\w+)/
        done()

    context 'when I click the "new view" button', ->
      before (done) ->
        wd40.click '.new-view', ->
          browser.waitForElementByCss '#chooser .tool', 4000, done

      context 'when I click on the newview tool', ->
        before (done) ->
          wd40.click '.newview.tool', =>
            browser.waitForElementByTagName 'iframe', 10000, =>
              browser.url (err, url) =>
                @currentUrl = url
                done()

        it 'takes me to the view page', ->
          @currentUrl.should.match new RegExp("#{url}/dataset/[^/]+/view/[^/]+")

  after (done) ->
    browser.quit ->
      done()
