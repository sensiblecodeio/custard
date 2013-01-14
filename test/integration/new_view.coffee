$ = jQuery = require 'jquery'
Browser = require 'zombie'
should = require 'should'

url = 'http://localhost:3001' # DRY DRY DRY
login_url = "#{url}/login"

describe 'Use a plugin to create a new view', ->
  browser = new Browser()
  browser.waitDuration = "10s"

  before (done) ->
    browser.visit login_url, done
    @datasetUrl = null
    @viewPathname = null

  before (done) ->
    browser.fill '#username', 'ehg'
    browser.fill '#password', 'testing'
    browser.pressButton '#login', ->
      browser.wait done

  context 'when I am on the datasets page', ->

    context 'when I click on a dataset', ->
      before (done) ->
        link = browser.query('a.dataset')
        browser.fire 'click', link, ->
          browser.wait 1000, ->
            browser.wait done

      it "takes me to the dataset's page", ->
        result = browser.location.href
        result.should.include "#{url}/dataset/"
        @datasetUrl = result

      context 'when I click on the Spreadsheet tool', ->
        before (done) ->
          link = browser.query('a.tool')
          browser.fire 'click', link, ->
            browser.wait 1000, ->
              browser.wait done

        it 'takes me to the new view', ->
          result = browser.location.href
          result.should.match /dataset[/][^/]+[/]view[/][^/]+/
          @viewPathname = browser.location.pathname

        it 'shows me stuff', ->

      context "when I return to the dataset's page", ->
        before (done) ->
          browser.visit @datasetUrl, done

        it 'lists the new view', ->
          link = browser.query("a.view[href='#{@viewPathname}']")
          should.exist link

      context "when I return to the dataset list", ->
        before (done) ->
          browser.visit "#{url}/", done

        it 'lists the new view', ->
          link = browser.query("a.view[href='#{@viewPathname}']")
          should.exist link
