should = require 'should'
{wd40, browser, base_url, login_url, home_url, prepIntegration} = require './helper'

describe 'Dashboard', ->
  prepIntegration()

  before (done) ->
    wd40.fill '#username', 'ehg', ->
      wd40.fill '#password', 'testing', ->
        wd40.click '#login', done

  context 'when I visit the dashboard page', ->
    before (done) ->
      browser.get "#{base_url}/dashboard", =>
        browser.waitForElementByCss '.dashboard h1', 4000, =>
          wd40.getText 'body', (err, text) =>
            @bodyText = text
            done()

    it 'I see datasets from all the accounts I can switch into', (done) ->
      @bodyText.should.include 'Chris Blower'
      @bodyText.should.include 'Prune'
      @bodyText.should.include 'Apricot'
      @bodyText.should.include 'Ickle Test'
      @bodyText.should.include 'Cheese'
      browser.elementsByCss 'tr.dataset', (err, elements) ->
        elements.length.should.equal 3
        done()

    it 'there are links to switch into each of those data hubs', (done) ->
      wd40.elementByCss 'a[href="/switch/ehg"]', (err, a) ->
        should.exist a
        wd40.elementByCss 'a[href="/switch/ickletest"]', (err, a) ->
          should.exist a
          done()

    it 'the data hubs are ordered alphabetically by name', (done) ->
      browser.elementsByCss '.dashboard h1', (err, h1s) ->
        h1s[0].text (err, text) ->
          text.should.include 'Chris Blower'
          h1s[1].text (err, text) ->
            text.should.include 'Ickle Test'
            done()

    it 'the datasets are shown in two separate lists', (done) ->
      browser.elementsByCss '.dashboard table', (err, elements) ->
        elements.length.should.equal 2
        done()

    it 'each dataset has an icon, name, owner, date created and status', (done) ->
      browser.elementsByCss 'tr.dataset td.icon', (err, elements) ->
        elements.length.should.equal 3
        browser.elementsByCss 'tr.dataset td.name', (err, elements) ->
          elements.length.should.equal 3
          browser.elementsByCss 'tr.dataset td.creator', (err, elements) ->
            elements.length.should.equal 3
            browser.elementsByCss 'tr.dataset td.created', (err, elements) ->
              elements.length.should.equal 3
              browser.elementsByCss 'tr.dataset td.status', (err, elements) ->
                elements.length.should.equal 3
                done()

    it 'there is a checkbox to show only failing datasets', (done) ->
      browser.elementByCss 'label#show-only-errors input', done

    it 'clicking the checkbox hides all non-failing datasets', (done) ->
      wd40.click 'label#show-only-errors input', ->
        wd40.waitForInvisibleByCss 'tr[data-box="3006375815"]', (err) ->
          wd40.waitForInvisibleByCss 'tr[data-box="3006375731"]', (err) ->
            browser.elementByCss 'tr[data-box="3006375730"]', (err, tr) ->
              tr.isVisible (err, visible) ->
                visible.should.be.true
                done()

    it 'clicking the checkbox again shows all datasets', (done) ->
      wd40.click 'label#show-only-errors input', ->
        wd40.waitForVisibleByCss 'tr[data-box="3006375815"]', done

    it 'clicking a dataset in someone else’s hub takes me to it (automatic context switch FTW)', (done) ->
      wd40.click 'tr[data-box="3006375730"] td.name', ->
        browser.waitForElementByCss '#toolbar', 4000, ->
          browser.waitForElementByCss 'iframe', 2000, done

