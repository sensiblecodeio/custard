require './setup_teardown'
should = require 'should'
{wd40, browser, loginAndGo} = require './helper'

describe 'Tool Privacy', ->

  context 'When ickletest (a free user) wants to make a new dataset', ->
    before (done) ->
      loginAndGo "ickletest", "toottoot", "/datasets", done

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
      loginAndGo "ehg", "testing", "/datasets", done

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
