should = require 'should'
{wd40, browser} = require('../wd40')

url = 'http://localhost:3001'

describe 'Pricing', ->
  before (done) ->
    wd40.init ->
      browser.get url + '/pricing', done

  before (done) =>
    wd40.getText 'body', (err, text) =>
      @bodyText = text
      # console.log text
      done()

  xit 'shows me a free "community" plan', =>
    @bodyText.toLowerCase().should.include 'community'

  it 'shows me a cheap "explorer" plan', =>
    @bodyText.toLowerCase().should.include 'explorer'

  it 'shows me an expensive "data scientist" plan', =>
    @bodyText.toLowerCase().should.include 'data scientist'

  it 'mentions our special corporate plans', =>
    @bodyText.toLowerCase().should.include 'corporate plans'

  context 'when I click the "explorer" plan', ->
    before (done) ->
      browser.elementByCssIfExists '.plan.explorer', (err, free) ->
        free.click done

    it 'takes me to the sign up page', (done) ->
      wd40.trueURL (err, url) ->
        url.should.include '/signup/explorer'
        done()

  after (done) ->
    browser.quit ->
      done()

