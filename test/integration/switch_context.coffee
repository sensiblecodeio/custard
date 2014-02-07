should = require 'should'
{wd40, browser, base_url, login_url, logout_url, home_url, prepIntegration} = require './helper'

request = require 'request'

describe 'Context switch (non-staff)', ->
  prepIntegration()

  before (done) ->
    wd40.fill '#username', 'test', ->
      wd40.fill '#password', 'testing', ->
        wd40.click '#login', done

  context 'when I click the context switcher', ->
    before (done) ->
      wd40.click '.context-switch', done

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
  prepIntegration()

  context 'When I log in as a staff member', ->
    before (done) ->
      wd40.fill '#username', 'teststaff', ->
        wd40.fill '#password', process.env.CU_TEST_STAFF_PASSWORD, ->
          wd40.click '#login', done

    context 'And I try to access a normal user’s dataset directly', ->
      before (done) ->
        browser.get "#{base_url}/dataset/1057304856/settings", done

      it 'I see the dataset contents', (done) ->
        browser.waitForElementByCss '#toolbar', 4000, ->
          browser.waitForElementByCss 'iframe', 2000, done

      it 'I have been automatically switched into the user’s account', (done) ->
        browser.get home_url, ->
          wd40.getText '#subnav-path', (err, text) ->
            text.should.not.include 'General Test Testington’s data hub'
            text.should.include 'Mr F Greedy’s data hub'
            done()
