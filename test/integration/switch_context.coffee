require './setup_teardown'
should = require 'should'
{wd40, browser, base_url, home_url, loginAndGo} = require './helper'

request = require 'request'

describe 'Context switch (non-staff)', ->

  before (done) ->
    loginAndGo "test", "testing", "/datasets", done

  context 'when I click the user menu', ->
    before (done) ->
      wd40.click '#header .dropdown-toggle', done

    it 'shows that I can switch into Ickle Test’s account', (done) ->
      wd40.waitForText "Ickle Test", done

    it 'shows that I can switch into Chris Blower’s account', (done) ->
      wd40.waitForText "Chris Blower", done

  context 'when I try to access one of Ickle Test’s datasets directly', ->
    before (done) ->
      browser.get "#{base_url}/dataset/3006375730/settings", done

    it 'I see the dataset contents', (done) ->
      browser.waitForElementByCss '#toolbar', 4000, ->
        browser.waitForElementByCss 'iframe', 2000, done

    it 'I have been automatically switched into the Ickle Test’s account', (done) ->
      browser.get home_url, ->
        wd40.elementByPartialLinkText 'Cheese', (err, element) ->
          should.exist element
          wd40.getText '#content', (err, text) ->
            text.should.not.include 'Prune'
            text.should.not.include 'Apricot'
            done()


describe 'Context switch (staff)', ->

  context 'When I log in as a staff member', ->
    before (done) ->
      loginAndGo "ehg", "testing", "/datasets", done

    context 'And I try to access a normal user’s dataset directly', ->
      before (done) ->
        browser.get "#{base_url}/dataset/1057304856/settings", done

      it 'I see the dataset contents', (done) ->
        browser.waitForElementByCss '#toolbar', 4000, ->
          browser.waitForElementByCss 'iframe', 2000, done

      it 'I have been automatically switched into the user’s account', (done) ->
        browser.get home_url, ->
          wd40.getText '#subnav-path', (err, text) ->
            text.should.not.include 'Chris Blower’s data hub'
            text.should.include 'Mr F Greedy’s data hub'
            done()

    context 'And I go back to my own', ->
      before (done) ->
        browser.get "#{base_url}/dataset/3006375815/settings", done

      it 'I see the dataset contents', (done) ->
        browser.waitForElementByCss '#toolbar', 4000, ->
          browser.waitForElementByCss 'iframe', 2000, done

      it 'I have been automatically switched back to my account', (done) ->
        browser.get home_url, ->
          wd40.getText '#subnav-path', (err, text) ->
            text.should.include 'Chris Blower’s data hub'
            text.should.not.include 'Mr F Greedy’s data hub'
            done()


describe 'Switch', ->

  nonstaff_user = 'ickletest'
  nonstaff_pass = 'toottoot'
  staff_user = 'teststaff'
  staff_pass = process.env.CU_TEST_STAFF_PASSWORD
  dataset_name = "Cheese" # in the fixture

  context 'when a staff member switches context', ->
    before (done) ->
      loginAndGo staff_user, staff_pass, "/switch/#{nonstaff_user}", done

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

    it 'shows the context switching menu', (done) ->
      browser.elementsByCss '#header .user li', (err, els) ->
        els.should.have.length 8
        browser.elementsByCss '#header .user .context', (err, els) ->
          els.should.have.length 2
          done()

  context 'when a non-staff member attempts to switch context', ->
    before (done) ->
      loginAndGo nonstaff_user, nonstaff_pass, "/switch/#{staff_user}", done

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

    it "it doesn't show the context switching menu", (done) ->
      browser.elementsByCss '#header .user li', (err, els) ->
        els.should.have.length 2 # settings and log out links
        done()


describe 'Unsuccessful switch', ->

  staff_user = 'teststaff'
  staff_pass = process.env.CU_TEST_STAFF_PASSWORD

  context 'when a staff member attempts to switch to a context that doesn\'t exist', ->
    before (done) ->
      loginAndGo staff_user, staff_pass, "/switch/IDONOTEXIST", done

    it "it shows them an error", (done) ->
      browser.source (err, text) ->
        text.toLowerCase().should.include 'user does not exist'
        done()