should = require 'should'
{wd40, browser, login_url, home_url, prepIntegration} = require './helper'

describe 'View', ->
  prepIntegration()

  randomname = "Prune graph number #{Math.random()}"

  before (done) ->
    wd40.fill '#username', 'ehg', ->
      wd40.fill '#password', 'testing', -> wd40.click '#login', done

  context 'when I click on an Prune dataset', ->
    before (done) ->
      # wait for tiles to fade in
      setTimeout ->
        browser.elementByPartialLinkText 'Prune', (err, link) ->
          link.click done
      , 500

    before (done) ->
      browser.elementByPartialLinkText 'Graph of Prunes', (err, link) ->
        link.click done

    it 'takes me to the Graph of Prunes page', (done) ->
      wd40.trueURL (err, result) ->
        result.should.match /\/dataset\/(\w+)/
        done()

    context 'when I go back', (done) ->
      before (done) ->
        browser.back done

      context 'when I click the "hide" link on the view', ->
        before (done) ->
          browser.elementByPartialLinkText "Graph of Prunes", (err, view) =>
            @view = view
            @view.elementByCss '.dropdown-toggle', (err, settingsLink) =>
              settingsLink.click =>
                @view.elementByCss '.hide-view', (err, hideLink) ->
                  hideLink.click done

        it 'the view disappears from the dataset page immediately', (done) ->
          # TODO: write a waitForInvisible function
          setTimeout =>
            @view.isVisible (err, visible) ->
              visible.should.be.false
              done()
          , 400

        context 'when I revisit the dataset page', ->
          before (done) ->
            browser.refresh done

          it 'the view stays hidden', (done) ->
            wd40.getText 'body', (err, text) ->
              text.should.not.include randomname
              done()
