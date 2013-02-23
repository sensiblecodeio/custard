$ = jQuery = require 'jquery'
Browser = require 'zombie'
should = require 'should'

url = 'http://localhost:3001' # DRY DRY DRY
login_url = "#{url}/login"

describe 'Dataset', ->
  randomname = "New favourite number is #{Math.random()}"
  browser = new Browser()
  browser.waitDuration = "10s"

  before (done) ->
    browser.visit login_url, done

  before (done) ->
    browser.fill '#username', 'ehg'
    browser.fill '#password', 'testing'
    browser.pressButton '#login', done

  # This test relies on a Cheese dataset created in api.coffee!!
  context 'when I click on a Cheese dataset', ->
    before (done) ->
      body = browser.query('body')
      link = $(body).find('.dataset:contains("Cheese")').first()[0]
      browser.fire 'click', link, ->
        browser.wait done

    it 'takes me to the Cheese dataset page', ->
      result = browser.location.href
      result.should.match /\/dataset\/(\w+)/

    it 'shows two tools I can use on this dataset', ->
      tools = browser.queryAll '.dataset-views .tool'
      tools.length.should.equal 2

    it 'has not shown the input box', ->
      @input = browser.query '#subnav-path input'
      $(@input).is(':visible').should.be.false

    context 'when I click the title', ->
      before (done) ->
        @input = browser.query '#subnav-path input'
        @a = browser.query '#subnav-path .editable'
        browser.fire 'click', browser.query('#subnav-path .editable'), done

      it 'an input box appears', ->
        should.exist @input
        $(@input).is(':visible').should.be.true

      context 'when I fill in the input box and press enter', ->
        before (done) ->
          browser.fill '#subnav-path input', randomname, ->
            browser.evaluate """
              var e = jQuery.Event("keyup")
              e.which = 13
              e.keyCode = 13
              $('#subnav-path input').trigger(e)
            """
            browser.wait done

        it 'hides the input box and shows the title', ->
          @input = browser.query '#subnav-path input'
          @a = browser.query '#subnav-path .editable'
          $(@a).is(':visible').should.be.true
          $(@input).is(':visible').should.be.false

        it 'has updated the title', (done) ->
          @a = browser.query '#subnav-path .editable'
          $(@a).text().should.equal randomname
          done()

      context 'when I go back home', ->
        before (done) ->
          browser.visit "#{url}/", ->
            browser.wait done

        it 'should display the home page', ->
          browser.location.href.should.match /\/$/

        it 'should show the new dataset new name', ->
          browser.text().should.include randomname

        context 'when I click the "hide" button on the dataset', ->
          before (done) ->
            body = browser.query('body')
            link = $(body).find(""".dataset:contains("#{randomname}") .hide""").first()[0]
            browser.fire 'click', link, ->
              browser.wait done

          it 'the dataset disappears from the homepage immediately', ->
            body = browser.query('body')
            # find datasets with the specified title, within a *visible* parent group
            naughty = $(body).find(""".dataset-group:visible .dataset:contains("#{randomname}")""")
            naughty.length.should.equal 0

          context 'when I revisit the homepage', ->
            before (done) ->
              browser.reload done

            it 'the dataset stays hidden', ->
              browser.text().should.not.include randomname

