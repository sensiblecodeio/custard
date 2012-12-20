$ = jQuery = require 'jquery'
Browser = require 'zombie'
should = require 'should'

url = 'http://localhost:3001' # DRY DRY DRY
login_url = "#{url}/login"

describe 'Dataset', ->
  randomname = "New favourite number is #{Math.random()}"
  browser = new Browser()

  before (done) ->
    browser.visit login_url, done

  before (done) ->
    browser.fill '#username', 'ickletest'
    browser.fill '#password', 'toottoot'
    browser.pressButton '#login', done

  context 'when I click on the newdataset dataset', ->
    before (done) ->
        link = browser.query('#tools .newdataset')
        browser.fire 'click', link, done

    it 'takes me to the highrise dataset page', ->
      result = browser.location.href
      result.should.equal "#{url}/tool/newdataset"

    it 'has not shown the input box', ->
      @input = browser.query '#header h2 input'
      $(@input).is(':visible').should.be.false

    context 'when I click the title', ->
      before (done) ->
        @input = browser.query '#header h2 input'
        @a = browser.query '#header h2 a'
        browser.fire 'click', browser.query('#header h2 a'), done

      it 'an input box appears', ->
        should.exist @input
        $(@input).is(':visible').should.be.true

      context 'when I fill in the input box and press enter', ->
        before (done) ->
          browser.fill '#header h2 input', randomname, ->
            browser.evaluate """
              var e = jQuery.Event("keypress")
              e.which = 13
              e.keyCode = 13
              $('#header h2 input').trigger(e)
            """
            browser.wait done

        it 'hides the input box and shows the title', ->
          @input = browser.query '#header h2 input'
          @a = browser.query '#header h2 a'
          $(@a).is(':visible').should.be.true
          $(@input).is(':visible').should.be.false

        it 'has updated the title', (done) ->
          @a = browser.query '#header h2 a'
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


