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

createProfile = (options, done) ->
  login 'teststaff', process.env.CU_TEST_STAFF_PASSWORD, (err, res, body) ->
    form =
      displayName: options.displayName
      email: options.email
    form.logoUrl = options.logoUrl if options.logoUrl?

    request.post
      uri: "#{BASE_URL}/api/#{options.shortName}"
      form: form
    , (err, resp, body) ->
      obj = JSON.parse body
      request.post
        uri: "#{BASE_URL}/api/token/#{obj.token}"
        form:
          password: options.password
      , done

describe 'Login', ->
  browser = null

  before (done) ->
    browser = new Browser()
    createProfile
      shortName: 'ickletest'
      displayName: 'Mr Ickle Test'
      password: 'toottoot'
      email: 'ickle@example.com'
    , done

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
        browser.text('#subnav-path').should.include 'Mr Ickle Test'

      xcontext 'when I logout', ->
        before (done) ->
          browser.fire 'click', browser.query('#userlink'), ->
            browser.fire 'click', browser.query('#userlinks .btn-primary'), done

        it 'redirects me to the login page', ->
          browser.location.href.should.equal "#{BASE_URL}/login"

        context 'when I visit the index page', ->
          it 'should still present a login form'

     xcontext 'when I try to login with my email address as my username', ->

describe 'Password', ->
  context 'when I use the password reset link', ->
    newUser = String(Math.random()).replace('0.', 'pass-')
    newPass = newUser
    before (done) ->
      login 'teststaff', process.env.CU_TEST_STAFF_PASSWORD, (err, res, body) =>
        form =
          displayName: newUser
          email: "pass@example.com"
        request.post
          uri: "#{BASE_URL}/api/#{newUser}"
          form: form
        , (err, resp, body) =>
          obj = JSON.parse body
          @browser = new Browser()
          @browser.visit "#{BASE_URL}/set-password/#{obj.token}", =>
            @browser.wait done

    it 'shows a page with a password field', ->
      should.exist @browser.query('#password')

    context 'when I fill in my new password', ->
      before (done) ->
        @browser.fill '#password', newPass
        @browser.pressButton '#content .btn-primary', =>
          @browser.wait done

      it 'sets my password', ->
        should.exist @browser.query('.alert-success')


describe 'Switch', ->

  nonstaff_user = 'ickletest'
  nonstaff_pass = 'toottoot'
  staff_user = 'teststaff'
  staff_pass = process.env.CU_TEST_STAFF_PASSWORD
  dataset_name = "dataset-#{String(Math.random()*Math.pow(2,32))[0..4]}"

  before (done) ->
    # log in as A
    login nonstaff_user, nonstaff_pass, (err, resp, body) ->
      request.post
        uri: "#{BASE_URL}/api/#{nonstaff_user}/datasets/"
        form:
          name: dataset_name
          displayName: dataset_name
          box: 'dummybox'
      , done

  before (done) ->
    @browser = new Browser()
    # Log in as B via zombie
    @browser.visit BASE_URL, =>
      @browser.fill '#username', staff_user
      @browser.fill '#password', staff_pass
      @browser.pressButton '#login', done

  context 'when a staff member switches context', ->
    before (done) ->
      @browser.visit "#{BASE_URL}/switch/#{nonstaff_user}", =>
        @browser.wait done

    it 'redirected to home page', ->
      @browser.location.href.should.equal "#{BASE_URL}/"

    it 'shows me datasets of the profile into which I have switched', ->
      @browser.text('.dataset-list').should.include dataset_name

    it "has the switched to profile's name", ->
      @browser.text('h1').should.include 'Mr Ickle Test'

    it "shows a gravatar", ->
      img = @browser.query('h1 img')
      img.src.should.include 'gravatar'

    it "shows the context search box", ->
      should.exist @browser.query('.context-switch')

  context 'when a non-staff member attempts to switch context', ->
    before (done) ->
      @browser = new Browser()
      @browser.visit BASE_URL, =>
        @browser.fill '#username', nonstaff_user
        @browser.fill '#password', nonstaff_pass
        @browser.pressButton '#login', =>
          @browser.visit "#{BASE_URL}/switch/#{staff_user}", =>
            @browser.visit BASE_URL, =>
              @browser.wait done

    it "hasn't changed who I am", ->
      @browser.text('h1').should.include 'Mr Ickle Test'
      @browser.text('h1').should.not.include 'Staff Test'

    it "still shows me my datasets", ->
      @browser.text('.dataset-list').should.include dataset_name

    it "doesn't show the context switching popup", ->
      should.not.exist @browser.query('.context-switch')

describe 'Whitelabel', ->

  browser = null
  corpProfile =
    shortName: 'evilcorp'
    displayName: 'Evil Corp'
    password: 'evilevil'
    email: 'mail@evil.com'
    logoUrl: "https://example.com/evil.png"

  before (done) ->
    createProfile corpProfile, done

  context 'when I log in to a corporate account', ->
    before (done) ->
      @browser = new Browser()
      @browser.visit BASE_URL, =>
        @browser.fill '#username', corpProfile.shortName
        @browser.fill '#password', corpProfile.password
        @browser.pressButton '#login', =>
          @browser.visit BASE_URL, =>
            @browser.wait done

    it 'shows my corporate logo somewhere', ->
      @browser.html().should.include """src="#{corpProfile.logoUrl}"""

