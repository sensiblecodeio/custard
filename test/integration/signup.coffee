should = require 'should'
{wd40, browser, base_url, login_url, home_url, prepIntegration} = require './helper'

describe 'Sign up', ->
  prepIntegration()


  context 'when I select the Free plan on the pricing page', ->
    before (done) ->
      browser.get "#{base_url}/pricing/", done
    before (done) ->
      wd40.click '.plan.community a', done

    context 'when I enter my details and click go', ->
      before (done) ->
        wd40.fill '#displayName', 'Tabatha Testington', ->
          # we clear the short name, which has been prefilled with a made up one for us
          # XXX test the text of the prefilled one is good
          wd40.clear '#shortName', ->
            wd40.fill '#shortName', 'tabbytest', ->
              wd40.fill '#email', 'tabby@example.org', ->
                wd40.click '#acceptedTerms', ->
                  wd40.click '#go', done

      it 'says thanks', (done) ->
        browser.waitForVisibleByCss '#thanks', 8000, done
