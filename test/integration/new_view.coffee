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

      xcontext 'when I click on the Code Your Own View tool', ->
        before (done) ->
          link = browser.query('a.code-your-own-view')
          browser.fire 'click', link, ->
            # Zarino isn't quite sure why we have
            # two levels of .wait() in here, but he's
            # going to leave it in just in case.
            browser.wait 1000, ->
              browser.wait done

        it 'takes me to the new view', ->
          result = browser.location.href
          result.should.match RegExp('dataset/[^/]+/view/[^/]+')
          @viewPathname = browser.location.pathname

      xcontext "when I return to the dataset's page", ->
        before (done) ->
          browser.visit @datasetUrl, done

        it 'lists the new view', ->
          link = browser.query("a.view[href='#{@viewPathname}']")
          should.exist link

      xcontext "when I return to the dataset list", ->
        before (done) ->
          browser.visit "#{url}/", done

        it 'lists the new view', ->
          link = browser.query("a.view[href='#{@viewPathname}']")
          should.exist link

        context 'when I click the "hide" button on the view', ->
          before (done) ->
            link = browser.query("a.view[href='#{@viewPathname}'] .delete")
            browser.fire 'click', link, ->
              browser.wait done

          it 'the view disappears from the homepage immediately', ->
            body = browser.query('body')
            naughty = $(body).find("a.view[href='#{@viewPathname}']:visible")
            naughty.length.should.equal 0

        context 'when I revisit the homepage', ->
          before (done) ->
            browser.reload done

          it 'the view stays hidden', ->
            naughty = browser.query("a.view[href='#{@viewPathname}']")
            should.not.exist naughty
