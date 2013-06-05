should = require 'should'
{wd40, browser, login_url, home_url, prepIntegration} = require './helper'

describe 'New view tool', ->
  prepIntegration()

  before (done) ->
    wd40.fill '#username', 'ehg', ->
      wd40.fill '#password', 'testing', ->
        wd40.click '#login', done

  context 'when I click on an Apricot dataset', ->
    before (done) ->
        wd40.elementByPartialLinkText 'Apricot', (err, link) ->
          link.click done

    it 'takes me to the Apricot dataset page', (done) ->
      wd40.trueURL (err, result) ->
        result.should.match /\/dataset\/(\w+)/
        done()

    context 'when I click on "More tools" in the toolbar', ->
      before (done) ->
        wd40.click '#toolbar .new-view', ->
          browser.waitForElementByCss '#chooser .tool', 4000, done

      context 'when I click on the newview tool', ->
        before (done) ->
          wd40.click '.newview.tool', =>
            # XXX but of a rubbish long wait - what CSS element could we wait for instead?
            setTimeout =>
              browser.url (err, url) =>
                @currentUrl = url
                done()
            , 2000

        it 'takes me to the view page', ->
          @currentUrl.should.match new RegExp("#{home_url}/dataset/[^/]+/view/[^/]+")
