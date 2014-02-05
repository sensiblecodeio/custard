should = require 'should'
{wd40, browser, base_url, login_url, home_url, prepIntegration} = require './helper'

describe 'Dashboard', ->
  prepIntegration()

  before (done) ->
    wd40.fill '#username', 'ehg', ->
      wd40.fill '#password', 'testing', ->
        wd40.click '#login', done

  before (done) ->
    browser.waitForElementByCss '.dataset-list', 4000, done

  context 'when I visit the dashboard page', ->
    before (done) ->
      browser.get "#{base_url}/dashboard", =>
        browser.waitForElementByCss '.dataset-list', 4000, =>
          wd40.getText 'body', (err, text) =>
            @bodyText = text
            done()

    it 'I see datasets from all the accounts I can switch into', (done) ->
      @bodyText.should.include 'Chris Blower’s data hub'
      @bodyText.should.include 'Prune'
      @bodyText.should.include 'Apricot'
      @bodyText.should.include 'Ickle Test’s data hub'
      @bodyText.should.include 'Cheese'
      browser.elementsByCss '.dataset-list > table tbody tr', (err, elements) ->
        elements.length.should.equal 3
        done()

    it 'the datasets are shown in a two separate lists', (done) ->
      browser.elementsByCss '.dataset-list > table', (err, elements) ->
        elements.length.should.equal 2
        done()

    it 'each dataset has an icon, name, owner, date created and status', (done) ->
      browser.elementsByCss '.dataset-list > table td.icon', (err, elements) ->
        elements.length.should.equal 3
        browser.elementsByCss '.dataset-list > table td.name', (err, elements) ->
          elements.length.should.equal 3
          browser.elementsByCss '.dataset-list > table td.creator', (err, elements) ->
            elements.length.should.equal 3
            browser.elementsByCss '.dataset-list > table td.created', (err, elements) ->
              elements.length.should.equal 3
              browser.elementsByCss '.dataset-list > table td.status', (err, elements) ->
                elements.length.should.equal 3
                done()
