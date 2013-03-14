wd = require 'wd'
should = require 'should'

browser = wd.remote()
wd40 = require('../wd40')(browser)

url = 'http://localhost:3001'

describe 'Pricing', ->
  before (done) ->
    wd40.init ->
      browser.get url + '/pricing', done

  it 'shows me a free plan', (done) ->
    browser.elementByCssIfExists '#plans .free', (err, free) ->
      should.exist free
      done()

  it 'shows me a cheap plan', (done) ->
    browser.elementByCssIfExists '#plans .cheap', (err, free) ->
      should.exist free
      done()

  it 'shows me an expensive plan', (done) ->
    browser.elementByCssIfExists '#plans .expensive', (err, free) ->
      should.exist free
      done()

  context 'when I click the free plan', ->
    before (done) ->
      browser.elementByCssIfExists '#plans .free', (err, free) ->
        free.click done

    it 'takes me to the sign up page', (done) ->
      wd40.trueURL (err, url) ->
        url.should.include '/signup/hacker'
        done()
