Browser = require 'zombie'
should = require 'should'

url = 'http://localhost:3000'
login_url = "#{url}/login"

describe 'Dataset', ->
  browser = new Browser()
  browser.features = "no-scripts css iframe"
  console.log browser.features

  before (done) ->
    browser.visit login_url, done

  before (done) ->
    browser.fill '#username', 'ickletest'
    browser.fill '#password', 'toottoot'
    browser.pressButton '#login', done

  context 'when I click on the highrise tool', ->
    before (done) ->
        link = browser.query('#datasets .highrise')
        browser.fire 'click', link, ->
          
          done()

    it 'takes me to the highrise dataset page', ->
      result = browser.location.href
      result.should.equal "#{url}/dataset/highrise"

    context 'when I click the title', ->
      before (done) ->
        browser.fire 'click', browser.query('#header h2 a'), done

      it 'lets me edit the title', (done) ->
        browser.fill '#header h2 input', 'Some lovely string'
        browser.evaluate """
          var e = jQuery.Event("keypress")
          e.which = 13
          $('#header h2 input').trigger(e)
        """
        done()

