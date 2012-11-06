phantom = require 'phantom'
should = require 'should'

url = 'http://localhost:3000'

describe 'Home page', ->
  page = null
  phantom_instance = null
  status = null

  before (done) ->
    phantom.create (phantom_arg) ->
      phantom_instance = phantom_arg
      phantom_instance.createPage (page_arg) ->
        page = page_arg
        page.set 'onConsoleMessage', (msg) ->
          console.log 'phantom', msg

        page.open url, (st) ->
          status = st
          done()

  it 'contains the scraperwiki logo', (done) ->
    page.evaluate (-> $('#header h1').text()), (result) ->
      result.should.equal 'Logo'
      done()

  context 'when I click on the highrise tool', ->
    before (done) ->
      page.evaluate (-> $('#tools .metro-tile').first().click()), -> done()

    it 'takes me to the highrise tool page', (done) ->
      page.evaluate (-> window.location.href), (result) ->
        result.should.equal "#{url}/tool/highrise"
        done()

    it 'shows the tool is loading', (done) ->
      page.evaluate (-> $('p.loading').length > 0), (result) ->
        result.should.be.true
        done()

    waitForTextMatch = (selector, regExp, callback) ->
      interval = null
      check = ->
        page.evaluate "function(){var v = $('#{selector}'); if(v) return v.text(); return ''}", (result) ->
            if result.match regExp
              clearInterval interval
              callback()
      interval = setInterval check, 500

    it 'displays the setup message of the tool', (done) ->
      waitForTextMatch '#content', /Enter your username and password/, done

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
        page.evaluate func, -> done()

      it 'outputs something after a little while', (done) ->
        waitForTextMatch '#highrise-setup .alert', /Great/, done

      it 'has now a crontab'

      it 'has made a JSON cookie', (done) ->
        page.evaluate "function(){return $.cookie('datasets')}", (result) ->
          parsed = JSON.parse result
          should.exist parsed
          done()

