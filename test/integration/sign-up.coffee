wd = require 'wd'
should = require 'should'

browser = wd.remote()
wd40 = require('../wd40')(browser)

url = 'http://localhost:3001'

describe 'Sign up', ->
  before (done) ->
    wd40.init ->
      browser.get "#{url}/signup/free", done

  context 'when I enter my details and click go', ->
    before (done) ->
      wd40.fill '#displayName', 'Tabatha Testington', ->
        wd40.fill '#shortName', 'tabbytest', ->
          wd40.fill '#email', 'tabby@example.org', ->
            wd40.click '#go', done

    it 'hides the form', (done) ->
        browser.elementByCss 'form.form-horizontal', (err, input) ->
          browser.isVisible input, (err, visible) ->
            visible.should.be.false
            done()

    it 'says thanks', (done) ->
        browser.elementByCss '#thanks', (err, input) ->
          browser.isVisible input, (err, visible) ->
            visible.should.be.true
            done()
