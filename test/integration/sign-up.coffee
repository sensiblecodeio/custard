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
      wd40.fill '#name', 'Tabatha Testington', ->
        wd40.fill '#username', 'tabbytest', ->
          wd40.fill '#email', 'tabby@example.org', ->
            wd40.click '#go', done

    it 'hides the form and says thanks', (done) ->
      wd40.trueURL (err, url) ->
        url.should.include '/signup/thanks'
        done()
