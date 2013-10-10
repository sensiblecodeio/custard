should = require 'should'
{wd40, browser, base_url, login_url, home_url, prepIntegration} = require './helper'

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
            wd40.waitForInvisibleByCss '#chooser', (err) =>
              browser.url (err, url) =>
                @currentUrl = url
                done()
            , 4000

        before (done) ->
          setTimeout done, 2000

        it 'takes me to the view page', (done) ->
          wd40.waitForMatchingURL new RegExp("#{base_url}/dataset/[^/]+/view/[^/]+"), done

    context 'when I click on "More tools" in the toolbar (again)', ->
      before (done) ->
        wd40.click '#toolbar .new-view', ->
          browser.waitForElementByCss '#chooser .tool', 4000, done

      context 'when I click on the newview tool', ->
        before (done) ->
          wd40.click '.newview.tool', (err) =>
            wd40.waitForInvisibleByCss '#chooser', (err) =>
              browser.url (err, url) =>
                @currentUrl = url
                done()
            , 4000

        it 'takes me to the view page', (done) ->
          wd40.waitForMatchingURL new RegExp("#{base_url}/dataset/[^/]+/view/[^/]+"), done

        it 'does not show two new view tools', (done) ->
          browser.elementsByCssSelector '[data-toolname=newview]', (err, tools) ->
            tools.length.should.equal 1
            done()
