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

    it 'shows the tools I can use on this dataset', ->
      tools = browser.queryAll '.dataset-tools .tool'
      tools.length.should.be.above 0

    xit 'shows the "Code your own View" tool', ->
      tools = browser.queryAll '.dataset-tools .tool'
      $(tools).text().toLowerCase().should.include 'code your own view'

    it 'has not shown the input box', ->
      @input = browser.query '#header h2 input'
      $(@input).is(':visible').should.be.false

    context 'when I click the title', ->
      before (done) ->
        @input = browser.query '#title input'
        @a = browser.query '#title .editable'
        browser.fire 'click', browser.query('#title .editable'), done

      it 'an input box appears', ->
        should.exist @input
        $(@input).is(':visible').should.be.true

      context 'when I fill in the input box and press enter', ->
        before (done) ->
          browser.fill '#title input', randomname, ->
            browser.evaluate """
              var e = jQuery.Event("keypress")
              e.which = 13
              e.keyCode = 13
              $('#title input').trigger(e)
            """
            browser.wait done

        it 'hides the input box and shows the title', ->
          @input = browser.query '#title input'
          @a = browser.query '#title .editable'
          $(@a).is(':visible').should.be.true
          $(@input).is(':visible').should.be.false

        it 'has updated the title', (done) ->
          @a = browser.query '#title .editable'
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
            link = $(body).find(""".dataset:contains("#{randomname}") .delete""").first()[0]
            browser.fire 'click', link, ->
              browser.wait done

          it 'the dataset disappears from the homepage immediately', ->
            browser.text().should.not.include randomname

          context 'when I revisit the homepage', ->
            before (done) ->
              browser.reload done

            it 'the dataset stays hidden', ->
              browser.text().should.not.include randomname

