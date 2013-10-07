should = require 'should'
{wd40, browser, base_url, login_url, home_url, prepIntegration} = require './helper'

describe 'Errors', ->
  prepIntegration()

  context 'when jQuery receives a 502 error from an AJAX call', ->
    before (done) ->
      wd40.fill '#username', 'ehg', ->
        wd40.fill '#password', 'testing', ->
          wd40.click '#login', done

    before (done) ->
      browser.waitForElementByCss '.dataset-list', 4000, done

    before (done) ->
      browser.eval "jQuery.ajax({url: 'http://httpbin.org/status/502'});", done

    it 'shows the error bar', (done) ->
      browser.waitForVisibleByCssSelector '#error-alert', 4000, done

    it 'displays a connection error', (done) ->
      wd40.getText '#error-alert', (err, text) ->
        text.should.include "We couldn't connect"
        done err
