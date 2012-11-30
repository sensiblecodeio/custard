Browser = require 'zombie'
should = require 'should'

url = 'http://localhost:3000'
login_url = "#{url}/login"

describe 'Home page', ->
  browser = new Browser()

  before (done) ->
    browser.visit login_url, done

  before (done) ->
    browser.fill '#username', 'ickletest'
    browser.fill '#password', 'toottoot'
    browser.pressButton '#login', done

  before (done) ->
    browser.visit url, done

  it 'contains the scraperwiki logo', (done) ->
    h = browser.text('#header h1')
    h.should.equal 'Logo'
    done()

  context 'when I click on the highrise tool', ->
    before (done) ->
      browser.fire 'click', browser.query('#tools .metro-tile'), done

    it 'takes me to the highrise tool page', ->
      result = browser.location.href
      result.should.equal "#{url}/tool/highrise"

    it 'shows the tool is loading', ->
      should.exist browser.query('p.loading')

    waitForTextMatch = (selector, regExp, callback) ->
      interval = null
      check = ->
        page.evaluate "function(){var v = $('#{selector}'); if(v) return v.text(); return ''}", (result) ->
          if result.match regExp
            clearInterval interval
            callback()
      interval = setInterval check, 500

    waitForElement = (selector, callback) ->
      interval = null
      check = ->
        page.evaluate "function(){var v = $('#{selector}'); return v.length}", (result) ->
          if result
            clearInterval interval
            callback()
      interval = setInterval check, 500

    it 'displays the setup message of the tool', (done) ->
      browser.wait (-> browser.query('#content')), ->
        (browser.text().match /Enter your username and password/).should.be.true
        done()

    context 'when I enter my details and click import', ->
      before (done) ->
        func = """
        function(){
          $('#username').val('#{process.env.HIGHRISE_USER}')
          $('#password').val('#{process.env.HIGHRISE_PASSWORD}')
          $('#domain').val('#{process.env.HIGHRISE_DOMAIN}')
          $('#import').click()
         }
        """
        page.evaluate func, ->
          waitForElement 'iframe', done

      it 'shows a lovely spreadsheet of our amazing data', (done) ->
        page.evaluate "function(){return $('iframe').attr('src')}", (result) ->
          m = result.match /spreadsheet-tool/
          should.exist m
          done()

      it 'has now a crontab'

      it 'has made a JSON cookie', (done) ->
        page.evaluate "function(){return $.cookie('datasets')}", (result) ->
          parsed = JSON.parse result
          should.exist parsed
          done()

