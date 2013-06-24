should = require 'should'
{wd40, browser, login_url, home_url, prepIntegration} = require './helper'

describe 'Professional Services', ->
  prepIntegration()

  before (done) ->
    browser.get "#{home_url}/professional/", ->
      browser.waitForElementByCss '#request form', 4000, done

  context 'when I enter my contact details', ->
    before (done) ->
      wd40.fill '#id_name', 'Steve Jobs', ->
        wd40.fill '#id_phone', '1-800-MY-APPLE', ->
          wd40.fill '#id_email', 'steve@example.com', ->
            wd40.fill '#id_description', 'Need data for thermonuclear war against android. Pls help. Kthxbai.', ->
              wd40.click '#request input[type="submit"]', done

    it 'says it’s loading', (done) ->
      wd40.elementByCss '#request input[type="submit"].loading', done

    it 'thanks me after a little while', (done) ->
      wd40.waitForInvisibleByCss '#request form', ->
        wd40.getText '#request #thanks', (err, text) ->
          text.should.include 'Thank you'
          done err

    it 'tells me my ticket ID', (done) ->
      wd40.getText '#request #thanks', (err, text) ->
        text.should.include 'ID'
        text.should.match /#\d+/
        done err

  context 'when I enter invalid details', ->
    before (done) ->
      browser.refresh done

    before (done) ->
      wd40.fill '#id_email', 'foobar', ->
        wd40.click '#request input[type="submit"]', done

    it 'asks me for my name', (done) ->
      wd40.elementByCss 'div.question.name .error', (err, div) ->
        div.text (err, text) ->
          text.should.include 'Please tell us your name'
          done err

    it 'asks for a valid email address', (done) ->
      wd40.elementByCss 'div.question.email .error', (err, div) ->
        div.text (err, text) ->
          text.should.include 'Please tell us your email address'
          done err
