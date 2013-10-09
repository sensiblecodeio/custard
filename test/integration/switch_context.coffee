should = require 'should'
{wd40, browser, base_url, login_url, home_url, prepIntegration} = require './helper'

request = require 'request'

describe 'Context switch', ->
  prepIntegration()

  before (done) ->
    wd40.fill '#username', 'ehg', ->
      wd40.fill '#password', 'testing', -> wd40.click '#login', done

  context 'when I click the context switcher', ->
    before (done) ->
      wd40.click '.context-switch', done

    it 'shows that I can switch into test', (done) ->
      wd40.waitForText "Ickle Test", done
