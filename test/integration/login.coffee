require './setup_teardown'
should = require 'should'
{wd40, browser, base_url, login_url, logout_url, home_url, prepIntegration} = require './helper'

request = require 'request'

# Overview
# Login as teststaff, create a profile called ickletest, attempt to login.
#
# Switching logs in as user A, adds a dataset using the API.
# Then we switch to a browser to switch the context.
#
# TODO: move Switching out into its own test file

login  = (username, password, callback) ->
  request.get login_url, ->
    request.post
      uri: login_url
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
      uri: "#{base_url}/api/user"
      form: form
    , (err, resp, body) ->
      obj = JSON.parse body
      request.post
        uri: "#{base_url}/api/token/#{obj.token}"
        form:
          password: options.password
      , done

describe 'Successful login', ->

  before (done) ->
    createProfile
      shortName: 'ickletest'
      displayName: 'Mr Ickle Test'
      password: 'toottoot'
      email: 'ickle@example.com'
    , done

  context 'when I visit the login page', ->
    before (done) ->
      browser.get login_url, done

    context 'when I try to login with valid details', ->
      before (done) ->
        wd40.fill '#username', 'ickletest', ->
          wd40.fill '#password', 'toottoot', ->
            wd40.click '#login', ->
              setTimeout done, 500

      it 'shows my name on the homepage', (done) ->
        wd40.getText '#subnav-path h1', (err, text) ->
          text.should.include 'Ickle Test'
          done()

      it 'shows my name in the nav bar', (done) ->
        wd40.getText '#header .user > a', (err, text) ->
          text.should.match /Ickle Test/i
          done()

      context 'when I revisit the login page', ->
        before (done) ->
          browser.get login_url, done

        it 'redirects me to my (logged in) home page', (done) ->
          wd40.trueURL (err, url) ->
            url.should.equal home_url
            done()

      context 'when I logout', ->
        before (done) ->
          browser.get home_url, done

        before (done) ->
          wd40.click '#header .user a.dropdown-toggle', ->
            wd40.click '#header .user .logout a', done

        it 'redirects me to the (logged out) home page', (done) ->
          wd40.trueURL (err, url) ->
            url.should.equal "#{base_url}/"
            done()


describe 'Failed login', ->

  before (done) ->
    createProfile
      shortName: 'ickletest'
      displayName: 'Mr Ickle Test'
      password: 'toottoot'
      email: 'ickle@example.com'
    , done

  context 'when I visit the login page', ->
    before (done) ->
      browser.get login_url, done

    context 'when I try to login with a non-existant username', ->
      before (done) ->
        wd40.fill '#username', 'IDONOTEXIST', ->
          wd40.fill '#password', 'toottoot', ->
            wd40.click '#login', ->
              setTimeout ->
                done()
              , 2000

      it 'it tells me the user does not exist', (done) ->
        wd40.getText '#error', (err, text) ->
          text.should.include 'user does not exist'
          done()

    context 'when I try to login with the wrong password', ->
      before (done) ->
        wd40.fill '#username', 'ickletest', ->
          wd40.fill '#password', 'INCORRECT', ->
            wd40.click '#login', ->
              done()

      it 'it tells me the password is wrong', (done) ->
        wd40.getText '#error', (err, text) ->
          text.should.include 'Incorrect password'
          done()


describe 'Whitelabel', ->

  corpProfile =
    shortName: 'evilcorp'
    displayName: 'Evil Corp'
    password: 'evilevil'
    email: 'mail@evil.com'
    logoUrl: "https://example.com/evil.png"
    isStaff: false

  before (done) ->
    createProfile corpProfile, done

  context 'when I log in to a corporate account', ->
    before (done) ->
      browser.deleteAllCookies done

    before (done) ->
      browser.get login_url, ->
        wd40.fill '#username', 'evilcorp', ->
          wd40.fill '#password', 'evilevil', ->
            wd40.click '#login', done

    it 'shows my corporate logo', (done) ->
      browser.waitForElementByCss "#subnav-path", 4000, ->
        browser.elementByCss "#subnav-path img", (err, element) ->
          element.getAttribute "src", (err, value) ->
            value.should.include corpProfile.logoUrl
            done()
