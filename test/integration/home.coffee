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
      page.evaluate (-> $('.metro-tile').first().click()), -> done()

    it 'takes me to the highrise tool page', (done) ->
      page.evaluate (-> window.location.href), (result) ->
        result.should.equal "#{url}/tool/highrise"
        done()

    it 'displays the setup message of the tool', (done) ->
        # Factor into a wait for predicate function?
        interval = null
        check = ->
          page.evaluate (-> $('#content').text()), (result) ->
            if result.match /Enter your username and password/
              clearInterval interval
              done()
        interval = setInterval check, 500


