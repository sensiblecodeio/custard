Browser = require 'zombie'
should = require 'should'
request = require 'request'

BASE_URL = 'http://localhost:3001'

# Overview
# Login as teststaff, create a profile called ickletest, attempt to login.
#
# Switching logs in as user A, adds a dataset using the API.
# Then we switch to zombie to switch the context.
#
# TODO: move Switching out into its own test file

login  = (username, password, callback) ->
  request.get "#{BASE_URL}/login", ->
    request.post
      uri: "#{BASE_URL}/login"
      form:
        username: username
        password: password
    , callback

createProfile = (name, password, done) ->
  login 'teststaff', process.env.CU_TEST_STAFF_PASSWORD, (err, res, body) ->
    request.post
      uri: "#{BASE_URL}/api/#{name}"
      form:
        displayName: 'Mr Ickle Test'
        email: 'ickle@example.com'

    , (err, resp, body) ->
      obj = JSON.parse body
      request.post
        uri: "#{BASE_URL}/api/token/#{obj.token}"
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
        browser.pressButton '#login', ->
          browser.wait done

      it 'shows my name', ->
        browser.text('nav').should.include 'Mr Ickle Test'

      it 'shows my datasets', ->
        browser.text('#title').should.include 'My Datasets'

      context 'when I logout', ->
        before (done) ->
          browser.fire 'click', browser.query('#userlink'), ->
            browser.fire 'click', browser.query('#userlinks .btn-primary'), done

        it 'redirects me to the login page', ->
          browser.location.href.should.equal "#{BASE_URL}/login"

        context 'when I visit the index page', ->
          it 'should still present a login form'

     context 'when I try to login with my email address as my username', ->

describe 'Switch', ->

  user_a = 'ickletest'
  pass_a = 'toottoot'
  user_b = 'teststaff'
  pass_b = process.env.CU_TEST_STAFF_PASSWORD
  dataset_name = "dataset-#{String(Math.random()*Math.pow(2,32))[0..4]}"

  before (done) ->
    # log in as A
    login user_a, pass_a, (err, resp, body) ->
      request.post
        uri: "#{BASE_URL}/api/#{user_a}/datasets/"
        form:
          name: dataset_name
          displayName: dataset_name
          box: 'dummybox'
      , done

  before (done) ->
    @browser = new Browser()
    # Log in as B via zombie
    @browser.visit BASE_URL, =>
      @browser.fill '#username', user_b
      @browser.fill '#password', pass_b
      @browser.pressButton '#login', done

  context 'when a staff member switches context', ->
    before (done) ->
      @browser.visit "#{BASE_URL}/switch/#{user_a}", =>
        @browser.wait done
    
    it 'redirected to home page', ->
      @browser.location.href.should.equal "#{BASE_URL}/"

    it 'shows me datasets of the profile into which I have switched', ->
      @browser.text('.dataset-list').should.include dataset_name

    it "has the switched to profile's name", ->
      @browser.text('.user').should.include 'Mr Ickle Test'

    it "shows a gravatar", ->
      img = @browser.query('.user a img')
      img.src.should.include 'gravatar'

  context 'when a non-staff member attempts to switch context', ->
    before (done) ->
      @browser = new Browser()
      @browser.visit BASE_URL, =>
        @browser.fill '#username', user_b
        @browser.fill '#password', pass_b
        @browser.pressButton '#login', =>
          @browser.visit "#{BASE_URL}/switch/#{user_a}", =>
            @browser.visit BASE_URL, =>
              @browser.wait done


    it "hasn't changed who I am", ->
      @browser.text('.user').should.include 'Mr Ickle Test'
      @browser.text('.user').should.not.include 'Staff Test'

    it "still shows me my datasets", ->
      @browser.text('.dataset-list').should.include dataset_name
