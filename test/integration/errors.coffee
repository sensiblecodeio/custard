require './setup_teardown'
should = require 'should'
{wd40, browser, loginAndGo} = require './helper'

describe 'Errors', ->

  context 'when jQuery receives a 502 error from an AJAX call', ->
    before (done) ->
      loginAndGo "ehg", "testing", "/datasets", done

    before (done) ->
      browser.eval "jQuery.ajax({url: 'http://httpbin.org/status/502'});", done

    it 'shows the error bar', (done) ->
      browser.waitForVisibleByCssSelector '#error-alert', 10000, done

    it 'displays a connection error', (done) ->
      wd40.getText '#error-alert', (err, text) ->
        text.should.include "We couldn't connect"
        done err
