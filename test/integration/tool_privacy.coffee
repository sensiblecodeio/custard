require './setup_teardown'
should = require 'should'
{wd40, browser, base_url, login_url, logout_url, home_url, prepIntegration} = require './helper'

describe 'Tool Privacy', ->
  prepIntegration()

  context 'When ickletest (a free user) wants to make a new dataset', ->
    before (done) ->
      browser.get login_url, ->
        wd40.fill '#username', 'ickletest', ->
          wd40.fill '#password', 'toottoot', ->
            wd40.click '#login', done

    before (done) ->
      wd40.click '.new-dataset', =>
        browser.waitForElementByCss '#chooser .tool', 4000, =>
          wd40.getText '#chooser', (err, text) =>
            @chooserText = text
            done()

    it 'He can see his private tool', ->
      @chooserText.should.include "Ickletest's private tool"
      @chooserText.should.include "Mine. All mine."

    it 'He can see the tool for free users', ->
      @chooserText.should.include "Special free user tool"
      @chooserText.should.include "A tool only published for users on the free plan"

  context 'When ehg (a grandfather user) wants to make a new dataset', ->
    before (done) ->
      browser.get logout_url, done

    before (done) ->
      browser.get login_url, ->
        wd40.fill '#username', 'ehg', ->
          wd40.fill '#password', 'testing', ->
            wd40.click '#login', done

    before (done) ->
      wd40.click '.new-dataset', =>
        browser.waitForElementByCss '#chooser .tool', 4000, =>
          wd40.getText '#chooser', (err, text) =>
            @chooserText = text
            done()

    it "He cannot see Ickletest's private tool", ->
      @chooserText.should.not.include "Ickletest's private tool"
      @chooserText.should.not.include "Mine. All mine."

    it 'He cannot see the tool for free users', ->
      @chooserText.should.not.include "Special free user tool"
      @chooserText.should.not.include "A tool only published for users on the free plan"
