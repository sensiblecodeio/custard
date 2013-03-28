should = require 'should'
{wd40, browser, login_url, home_url, prepIntegration} = require './helper'

describe 'Sign up', ->
  prepIntegration()

  before (done) ->
    browser.get "#{home_url}/signup/hacker", done

  context 'when I enter my details and click go', ->
    before (done) ->
      wd40.fill '#displayName', 'Tabatha Testington', ->
        # we clear the short name, which has been prefilled with a made up one for us
        # XXX test the text of the prefilled one is good
        wd40.clear '#shortName', ->
          wd40.fill '#shortName', 'tabbytest', ->
            wd40.fill '#email', 'tabby@example.org', ->
              wd40.fill '#inviteCode', process.env.CU_INVITE_CODE, ->
                wd40.click '#go', done

    it 'says thanks', (done) ->
      browser.waitForVisibleByCss '#thanks', 4000, done
