should = require 'should'
{wd40, browser, base_url, login_url, home_url, prepIntegration} = require './helper'

describe 'View', ->
  prepIntegration()

  randomname = "Prune graph number #{Math.random()}"

  before (done) ->
    wd40.fill '#username', 'ehg', ->
      wd40.fill '#password', 'testing', ->
        wd40.click '#login', done

  before (done) ->
    browser.waitForElementByCss '.dataset-list', 4000, done

  context 'when I click on a Prune dataset then the graph of prunes view', ->
    before (done) ->
      browser.elementByPartialLinkText 'Prune', (err, link) ->
        link.click done

    before (done) ->
      wd40.click '#toolbar .tool[data-toolname="prune-graph"] .tool-icon', done

    it 'takes me to the Graph of Prunes page', (done) ->
      wd40.trueURL (err, result) ->
        result.should.match /\/view\/(\w+)/
        done()

    it 'there is a custom-named "Data Scientist\'s Report" tool', (done) ->
      wd40.getText '#dataset-tools', (err, text) ->
        text.replace(/\s+/g, ' ').toLowerCase().should.include "data scientist's report"
        done()

    context 'when I click the "hide" link on the "Code a prune" tool', ->
      before (done) ->
          browser.elementByCss '#toolbar .tool[data-toolname="prune-graph"]', (err, el) ->
            el.elementByCss '.dropdown-toggle', (err, optionsToggle) ->
              optionsToggle.click (err) ->
                 wd40.click '#tool-options-menu .hide-tool', done

      it "I'm redirected to the dataset's default tool", (done) ->
        wd40.waitForMatchingURL /dataset[/]\w+([/]settings)?[/]?$/, done

      it 'And the "Code a prune" tool is no longer visible', (done) ->
        browser.elementByCss '#toolbar .tool[data-toolname="prune-graph"]', (err, el) ->
          should.not.exist el
          done()
