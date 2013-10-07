should = require 'should'
{wd40, browser, base_url, login_url, home_url, prepIntegration} = require './helper'

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
  prepIntegration()

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

      it 'shows my name', (done) ->
        # change "does not show my name" below as well if you change this
        wd40.getText '#subnav-path .btn', (err, text) ->
          text.should.include 'Ickle Test'
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
          wd40.click '#header .logout a', done

        it 'redirects me to the (logged out) home page', (done) ->
          wd40.trueURL (err, url) ->
            url.should.equal "#{base_url}/"
            done()


describe 'Failed login', ->
  prepIntegration()

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
              , 500

      it 'it tells me the user does not exist', (done) ->
        wd40.getText '#error', (err, text) ->
          text.should.include 'user does not exist'
          done()

      it 'it suggests I try logging into ScraperWiki Classic', (done) ->
        wd40.elementByCss '#error a[href="https://classic.scraperwiki.com"]', (err, link) ->
          should.exist link
          done()

    context 'when I try to login with the wrong password', ->
      before (done) ->
        wd40.fill '#username', 'ickletest', ->
          wd40.fill '#password', 'INCORRECT', ->
            wd40.click '#login', ->
              setTimeout ->
                done()
              , 500

      it 'it tells me the password is wrong', (done) ->
        wd40.getText '#error', (err, text) ->
          text.should.include 'Incorrect password'
          done()


describe 'Password', ->
  prepIntegration()

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
          uri: "#{base_url}/api/user"
          form: form
        , (err, resp, body) =>
          obj = JSON.parse body
          @token = obj.token
          done()

    before (done) ->
      browser.deleteAllCookies done

    before (done) ->
      browser.get "#{base_url}/set-password/#{@token}", done

    it 'shows my username', (done) ->
      wd40.getText '#content', (err, text) ->
        text.should.include newUser
        done()

    it 'shows a page with a password field', (done) ->
      browser.elementByCssIfExists '#password', (err, element) ->
        should.exist element
        done()

    context 'when I fill in my new password', ->
      before (done) ->
        wd40.fill '#password', newPass, ->
          wd40.click '#content .btn-primary', done

      it 'redirected to home page', (done) ->
        wd40.waitForText "data hub", ->
          wd40.trueURL (err, url) ->
            url.should.equal home_url
            done()


describe 'Switch', ->
  prepIntegration()


  nonstaff_user = 'ickletest'
  nonstaff_pass = 'toottoot'
  staff_user = 'teststaff'
  staff_pass = process.env.CU_TEST_STAFF_PASSWORD
  dataset_name = "Cheese" # in the fixture

  before (done) ->
    browser.deleteAllCookies done

  before (done) ->
    # Log in as B via selenium
    browser.get login_url, ->
      wd40.fill '#username', staff_user, ->
        wd40.fill '#password', staff_pass, ->
          wd40.click '#login', done

  context 'when a staff member switches context', ->
    before (done) ->
      browser.get "#{base_url}/switch/#{nonstaff_user}", done

    it 'redirected to home page', (done) ->
      wd40.trueURL (err, url) ->
        url.should.equal home_url
        done()

    it 'shows me datasets of the profile into which I have switched', (done) ->
      wd40.getText '.dataset-list', (err, text) ->
        text.should.include dataset_name
        done()

    it "has the switched to profile's name", (done) ->
      wd40.getText 'h1', (err, text) ->
        text.should.include 'Ickle Test'
        done()

    it 'shows a gravatar', (done) ->
      browser.elementByCss "h1 img", (err, element) ->
        element.getAttribute "src", (err, value) ->
          value.should.include 'gravatar'
          done()

    it 'shows the context search box', (done) ->
      browser.waitForVisibleByCss '.context-switch', 4000, done

  context 'when a non-staff member attempts to switch context', ->
    before (done) ->
      browser.deleteAllCookies done

    before (done) ->
      browser.get login_url, ->
        wd40.fill '#username', nonstaff_user, ->
          wd40.fill '#password', nonstaff_pass, ->
            wd40.click '#login', ->
              browser.get "#{base_url}/switch/#{staff_user}", done

    it 'it shows an error message', (done) ->
      browser.source (err, text) ->
        text.toLowerCase().should.include 'cannot switch'
        done()
      # might also want to check the 403 HTTP status??

    it "it hasn't changed who I am", (done) ->
      browser.get home_url, ->
        wd40.getText 'h1', (err, text) ->
          text.should.include 'Ickle Test'
          wd40.getText 'h1', (err, text) ->
            text.should.not.include 'Testington'
            done()

    it 'it still shows me my datasets', (done) ->
      wd40.getText '.dataset-list', (err, text) ->
        text.should.include dataset_name
        done()

    it "it doesn't show the context switching popup", (done) ->
      browser.elementByCss '.context-switch', (err, element) ->
        browser.isVisible element, (err, visible) ->
          visible.should.be.true
          done()


describe 'Unsuccessful switch', ->
  prepIntegration()

  staff_user = 'teststaff'
  staff_pass = process.env.CU_TEST_STAFF_PASSWORD

  context 'when a staff member attempts to switch to a context that doesn\'t exist', ->
    before (done) ->
      browser.deleteAllCookies done

    before (done) ->
      browser.get login_url, ->
        wd40.fill '#username', staff_user, ->
          wd40.fill '#password', staff_pass, ->
            wd40.click '#login', done

    before (done) ->
      browser.get "#{base_url}/switch/IDONOTEXIST", done

    it "it shows them an error", (done) ->
      browser.source (err, text) ->
        text.toLowerCase().should.include 'user does not exist'
        done()


describe 'Whitelabel', ->
  prepIntegration()

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
