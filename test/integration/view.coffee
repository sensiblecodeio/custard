should = require 'should'
{wd40, browser, login_url, home_url, prepIntegration} = require './helper'

describe 'View', ->
  prepIntegration()

  randomname = "Prune graph number #{Math.random()}"

  before (done) ->
    wd40.fill '#username', 'ehg', ->
      wd40.fill '#password', 'testing', -> wd40.click '#login', done

  context 'when I click on an Prune dataset then the graph of prunes view', ->
    before (done) ->
      # wait for tiles to fade in
      setTimeout ->
        browser.elementByPartialLinkText 'Prune', (err, link) ->
          link.click done
      , 1000

    before (done) ->
      browser.elementByPartialLinkText 'Tools', (err, link) =>
        link.click done

    before (done) ->
      browser.elementByPartialLinkText 'Code a prune!', (err, link) ->
        link.click done

    it 'takes me to the Graph of Prunes page', (done) ->
      wd40.trueURL (err, result) ->
        result.should.match /\/dataset\/(\w+)/
        done()

    context 'when I open the Tools menu', ->
      before (done) ->
        browser.elementByPartialLinkText 'Tools', (err, link) ->
          link.click done

      context 'when I click the "hide" link on the "Code a prune" tool', ->
        before (done) ->
          browser.elementByPartialLinkText "Code a prune", (err, view) =>
            @link = view
            browser.moveTo @link, =>
              @link.elementByCss '.hide', (err, hideLink) ->
                hideLink.click done

        it 'the tool disappears from the tool menu immediately', (done) ->
          # TODO: write a waitForInvisible function
          setTimeout ->
            browser.elementByPartialLinkTextIfExists "Code a prune", (err, view) ->
              should.not.exist view
              done()
          , 400

        context 'when I reload the page', ->
          before (done) ->
            browser.refresh done

          it 'the "Code a prune" tool stays hidden', (done) ->
            browser.elementByPartialLinkText 'Tools', (err, link) =>
              browser.moveTo link, ->
                link.click ->
                  browser.elementByPartialLinkTextIfExists "Code a prune", (err, view) ->
                    should.not.exist view
                    done()
