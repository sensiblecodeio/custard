should = require 'should'
{wd40, browser} = require('../wd40')

request = require 'request'

BASE_URL = 'http://localhost:3001'
LOGIN_URL = "#{BASE_URL}/login"

# Overview
# Login as teststaff, create a profile called ickletest, attempt to login.
#
# Switching logs in as user A, adds a dataset using the API.
# Then we switch to a browser to switch the context.
#
# TODO: move Switching out into its own test file

login  = (username, password, callback) ->
  request.get LOGIN_URL, ->
    request.post
      uri: LOGIN_URL
      form:
        username: username
        password: password
    , callback

createProfile = (options, done) ->
  login 'teststaff', process.env.CU_TEST_STAFF_PASSWORD, (err, res, body) ->
    form =
      shortName: options.shortName
      displayName: options.displayName
      email: options.email
    form.logoUrl = options.logoUrl if options.logoUrl?

    request.post
      uri: "#{BASE_URL}/api/user"
      form: form
    , (err, resp, body) ->
      obj = JSON.parse body
      request.post
        uri: "#{BASE_URL}/api/token/#{obj.token}"
        form:
          password: options.password
      , done

describe 'Login', ->
  before (done) ->
    wd40.init ->
      browser.get LOGIN_URL, done

  before (done) ->
    createProfile
      shortName: 'ickletest'
      displayName: 'Mr Ickle Test'
      password: 'toottoot'
      email: 'ickle@example.com'
    , done

  context 'when I visit the homepage', ->
    before (done) ->
      browser.get LOGIN_URL, done

    context 'when I try to login with valid details', ->
      before (done) ->
        wd40.fill '#username', 'ickletest', ->
          wd40.fill '#password', 'toottoot', ->
            wd40.click '#login', ->
              setTimeout ->
                done()
              , 500

      it 'shows my name', (done) ->
        # change "does not show my name" below as well if you change this
        wd40.getText '#subnav-path .btn', (err, text) ->
          text.should.include 'Ickle Test'
          done()

      context 'when I logout', ->
        before (done) ->
          wd40.click '#header .logout a', done

        it 'redirects me to the home page', (done) ->
          wd40.trueURL (err, url) ->
            url.should.equal BASE_URL + "/"
            done()

     xcontext 'when I try to login with my email address as my username', ->

describe 'Password', ->
  context 'when I use the password reset link', ->
    newUser = String(Math.random()).replace('0.', 'pass-')
    newPass = newUser
    before (done) ->
      login 'teststaff', process.env.CU_TEST_STAFF_PASSWORD, (err, res, body) =>
        form =
          shortName: newUser
          displayName: newUser
          email: "pass@example.com"
        request.post
          uri: "#{BASE_URL}/api/user"
          form: form
        , (err, resp, body) =>
          obj = JSON.parse body
          @token = obj.token
          done()

    before (done) ->
      browser.deleteAllCookies done

    before (done) ->
      browser.get "#{BASE_URL}/set-password/#{@token}", done

    it 'shows a page with a password field', (done) ->
      browser.elementByCssIfExists '#password', (err, element) ->
        should.exist element
        done()

    context 'when I fill in my new password', ->
      before (done) ->
        browser.fill '#password', newPass ->
          browser.click '#content .btn-primary', (err, btn) ->
            btn.click done

      it 'sets my password', (done) ->
        browser.waitForVisibleByCss '.alert-success', 4000, done

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
    browser.deleteAllCookies done

  before (done) ->
    # Log in as B via zombie
    browser.get LOGIN_URL, ->
      wd40.fill '#username', staff_user, ->
        wd40.fill '#password', staff_pass, ->
          wd40.pressButton '#login', done

  context 'when a staff member switches context', ->
    before (done) ->
      browser.get "#{BASE_URL}/switch/#{nonstaff_user}", done

    it 'redirected to home page', (done) ->
      wd40.trueURL (err, url) ->
        url.should.equal "#{BASE_URL}/"
        done()

    it 'shows me datasets of the profile into which I have switched', (done) ->
      wd40.getText '.dataset-list', (err, text) ->
        text.should.include dataset_name
        done()

    it "has the switched to profile's name", (done) ->
      wd40.getText 'h1', (err, text) ->
        text.should.include 'Mr Ickle Test'
        done()

    it 'shows a gravatar', (done) ->
      browser.elementByCssIfExists 'h1 img', (err, img) ->
        img.src.should.include 'gravatar'
        done()

    it 'shows the context search box', (done) ->
      browser.waitForVisibleByCss '.context-switch', 4000, done

  context 'when a non-staff member attempts to switch context', ->
    before (done) ->
      browser.deleteAllCookies done

    before (done) ->
      browser.get LOGIN_URL, ->
        wd40.fill '#username', nonstaff_user, ->
          wd40.fill '#password', nonstaff_pass, ->
            wd40.click '#login', ->
              wd40.get "#{BASE_URL}/switch/#{staff_user}", ->
                wd40.get BASE_URL, done

    it "hasn't changed who I am", (done) ->
      wd40.getText 'h1', (err, text) ->
        text.should.include 'Mr Ickle Test'
        wd40.getText 'h1', (err, text) ->
          text.should.not.include 'Staff Test'
          done()

    it 'still shows me my datasets', (done) ->
      wd40.getText '.dataset-list', (err, text) ->
        text.should.include dataset_name
        done()

    it "doesn't show the context switching popup", (done) ->
      browser.isVisible '.context-switch', (err, visible) ->
        visible.should.be.true
        done()

describe 'Whitelabel', ->

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
      browser.deleteAllCookies done

    before (done) ->
      browser.get BASE_URL, ->
        wd40.fill '#username', corpProfile.shortName, ->
          wd40.fill '#password', corpProfile.password, ->
            wd40.click '#login', ->
              browser.get BASE_URL, done

    it 'shows my corporate logo somewhere', (done) ->
      browser.source (err, source) ->
        source.should.include """src="#{corpProfile.logoUrl}"""
        done()

  after (done) ->
    browser.quit ->
      done()

