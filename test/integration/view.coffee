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

    # :TODO: toolbar (done?)
    before (done) ->
      wd40.elementByPartialLinkText 'Code a prune!', (err, toolLink) ->
        toolLink.click done

    it 'takes me to the Graph of Prunes page', (done) ->
      wd40.trueURL (err, result) ->
        result.should.match /\/view\/(\w+)/
        done()

    it 'there is a custom-named "Data Scientist\'s Report" tool', (done) ->
      wd40.getText '#dataset-tools', (err, text) ->
        text.toLowerCase().should.include "data scientist's report"
        done()

    context 'when I click the "hide" link on the "Code a prune" tool', ->
      before (done) ->
        wd40.elementByCss '#dataset-tools', (err, menu) ->
          menu.elementByPartialLinkText "Code a prune", (err, view) =>
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
        , 1000

      it "and I'm redirected to the dataset's default tool", (done) ->
        wd40.waitForMatchingURL /dataset[/]\w+([/]settings)?[/]?$/, done
