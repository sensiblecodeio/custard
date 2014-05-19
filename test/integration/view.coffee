require './setup_teardown'
should = require 'should'
{wd40, browser, loginAndGo} = require './helper'

describe 'View', ->
  randomname = "Prune graph number #{Math.random()}"

  before (done) ->
    loginAndGo "ehg", "testing", "/datasets", done

  context 'when I click on a Prune dataset then the graph of prunes view', ->
    before (done) ->
      wd40.elementByPartialLinkText 'Prune', (err, link) ->
        link.click done

    before (done) ->
      wd40.waitForVisibleByCss '#toolbar .tool[data-toolname="prune-graph"] .tool-icon', ->
        wd40.click '#toolbar .tool[data-toolname="prune-graph"] .tool-icon', done

    it 'takes me to the Graph of Prunes page', (done) ->
      wd40.waitForMatchingURL /\/view\/(\w+)/, (err, url) ->
        done()

    it 'there is a custom-named "Data Scientist\'s Report" tool', (done) ->
      wd40.getText '#dataset-tools', (err, text) ->
        text.replace(/\s+/g, ' ').toLowerCase().should.include "data scientist's report"
        done()

    context 'when I click the "hide" link on the "Code a prune" tool', ->
      before (done) ->
          wd40.elementByCss '#toolbar .tool[data-toolname="prune-graph"]', (err, el) ->
            el.elementByCss '.dropdown-toggle', (err, optionsToggle) ->
              optionsToggle.click (err) ->
                 wd40.click '#tool-options-menu .hide-tool', done

      it "I'm redirected to the dataset's default tool", (done) ->
        wd40.waitForMatchingURL /dataset[/]\w+([/]settings)?[/]?$/, done

      it 'And the "Code a prune" tool is no longer visible', (done) ->
        # we use browser, and not wd40, here because wd40
        # would timeout waiting for the element to appear
        browser.elementByCss '#toolbar .tool[data-toolname="prune-graph"]', (err, el) ->
          should.not.exist el
          done()
