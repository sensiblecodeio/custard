should = require 'should'
{wd40, browser, base_url, login_url, home_url, prepIntegration} = require './helper'

describe 'Home page (logged in)', ->
  prepIntegration()

  before (done) ->
    wd40.fill '#username', 'ehg', ->
      wd40.fill '#password', 'testing', ->
        wd40.click '#login', done

  before (done) ->
    browser.waitForElementByCss '.dataset-list', 4000, done

  it 'contains the scraperwiki logo', (done) ->
    wd40.getText '#logo', (err, h) ->
      h.should.equal 'ScraperWiki'
      done()

  it 'shows my datasets as big rectangular tiles', (done) ->
    browser.waitForVisibleByCss '.dataset', 4000, ->
      browser.elementsByCss '.dataset.tile', (err, datasets) ->
        should.exist datasets
        datasets.length.should.be.above 0
        done()

  it 'each dataset has a visible status', (done) ->
    browser.elementsByCss '.dataset .status', (err, elements) ->
      should.exist elements
      elements.length.should.be.above 0
      done()

  it 'shows that each dataset was created by Chris Blower', (done) ->
    browser.elementsByCss '.dataset .owner', (err, elements) ->
      should.exist elements
      elements.length.should.equal 2
      done()

  it 'the datasets are ordered by date created, newest at the top', (done) ->
    wd40.getText 'body', (err, text) ->
      text.split('Prune')[1].should.include('Apricot')
      done()

  it 'it lets me switch to a more information-dense list view', (done) ->
    browser.elementsByCss '#tile-view, #list-view', (err, elements) ->
      should.exist elements
      elements.length.should.equal 2
      done()

  it 'it shows that the tile view is currently active', (done) ->
    browser.elementsByCss '#tile-view.active', (err, elements) ->
      should.exist elements
      elements.length.should.equal 1
      done()

  context 'when I click the list view button', (done) ->
    before (done) ->
      wd40.click '#list-view', done

    it 'it shows my datasets in a list', (done) ->
      wd40.elementByCss 'table.dataset-list', (err, element) ->
        should.exist element
        browser.elementsByCss 'table.dataset-list tbody tr', (err, elements) ->
          elements.length.should.equal 2
          done()

    it 'each dataset has an icon, a name, owner, date created and a status', (done) ->
      browser.elementsByCss 'table.dataset-list td.icon', (err, elements) ->
        elements.length.should.equal 2
        browser.elementsByCss 'table.dataset-list td.name', (err, elements) ->
          elements.length.should.equal 2
          browser.elementsByCss 'table.dataset-list td.owner', (err, elements) ->
            elements.length.should.equal 2
            browser.elementsByCss 'table.dataset-list td.created', (err, elements) ->
              elements.length.should.equal 2
              browser.elementsByCss 'table.dataset-list td.status', (err, elements) ->
                elements.length.should.equal 2
                done()

    it 'the list is ordered by date created, newest at the top', (done) ->
      wd40.getText 'table.dataset-list', (err, text) ->
        text.split('Prune')[1].should.include('Apricot')
        done()

  context 'when I reload the page', ->

    before (done) ->
      browser.refresh(done)

    it 'it still shows my datasets in a list', (done) ->
      wd40.elementByCss 'table.dataset-list', (err, element) ->
        should.exist element
        done()

  context 'when I click the "new dataset" button', ->
    before (done) ->
      wd40.click '.new-dataset', done

    it 'shows the tools I can use to create datasets', (done) ->
      browser.waitForElementByCss '#chooser .tool', 4000, ->
        browser.elementsByCss '#chooser .tool', (err, tools) ->
          tools.length.should.be.above 0
          done()
