Browser = require 'zombie'
should = require 'should'
request = require 'request'

BASE_URL = 'http://localhost:3000'
INT_TEST_SRV = 'https://boxecutor-dev-1.scraperwiki.net'

createProfile = (name, password, done) ->
  request.post
    uri: "#{INT_TEST_SRV}/#{name}"
    form:
      apikey: process.env.COTEST_STAFF_API_KEY
      displayname: 'Mr Ickle Test'
      email: 'ickle@example.com'

  , (err, resp, body) ->
    obj = JSON.parse body
    request.post
      uri: "#{INT_TEST_SRV}/token/#{obj.token}"
      form:
        password: password
    , done

describe 'Login', ->
  browser = null

  before (done) ->
    browser = new Browser()
    createProfile 'ickletest', 'toottoot', done

  context 'when I visit the homepage', ->
    before (done) ->
      browser.visit BASE_URL, done

    context 'when I am not logged in', ->
      it 'shows me a login form', ->
        should.exist browser.query('form')

    context 'when I try to login with valid details', ->
      before (done) ->
        browser.fill '#username', 'ickletest'
        browser.fill '#password', 'toottoot'
        browser.pressButton '#login', done

      it 'shows my name', ->
        browser.text('body').should.include 'Mr Ickle Test'

      it 'shows my datasets', ->
        browser.text('body').should.include 'Your Datasets'
