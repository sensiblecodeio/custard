should = require 'should'
{wd40, browser, base_url, login_url, home_url, prepIntegration} = require './helper'

# Imagine the scene: a free user with a single dataset has recently upgraded.
# She creates a new view on that dataset. Her dataset box is on the free server,
# but her view box is on the paid server. This test ensures that both tools
# are passed the right boxServer values via the iframe settings hash.

describe 'Tool Content', ->
  prepIntegration()

  before (done) ->
    browser.get login_url, ->
      wd40.fill '#username', 'recentlyUpgraded', ->
        wd40.fill '#password', 'testing', ->
          wd40.click '#login', done

  context "When a recently upgraded user visits an old dataset", ->
    before (done) ->
      # wait for tiles to fade in
      setTimeout ->
        wd40.elementByPartialLinkText 'Old Dataset', (err, link) ->
          link.click done
      , 500

    before (done) =>
      wd40.elementByCss 'iframe', (err, iframe) =>
         return done(err) if err?
         iframe.getAttribute 'src', (err, src) =>
           return done(err) if err?
           @settingsHash = JSON.parse decodeURIComponent src.split('#')[1]
           done()

    it 'the URL ends with /settings becuase the dataset has no table view', (done) ->
      wd40.trueURL (err, result) ->
        result.should.match /\/dataset\/(\w+)\/settings$/
        done()

    it 'the iframe hash includes settings for only a source and not a target', =>
      Object.keys(@settingsHash).should.eql ['source']

    it 'iframe hash includes a source box name', =>
      should.exist @settingsHash.source.box

    it 'the iframe hash includes a source apikey', =>
      should.exist @settingsHash.source.apikey

    it 'the iframe hash includes a source box url', =>
      should.exist @settingsHash.source.url

    it 'the source box url is on the free server', =>
      @settingsHash.source.url.should.match /^http:\/\/free-server/

  context "When the user visits a recently created view on a different server", ->
    before (done) ->
      wd40.click '#toolbar .tool[data-toolname="newview"] .tool-icon', done

    before (done) =>
      wd40.elementByCss 'iframe', (err, iframe) =>
         return done(err) if err?
         iframe.getAttribute 'src', (err, src) =>
           return done(err) if err?
           @settingsHash = JSON.parse decodeURIComponent src.split('#')[1]
           done()

    it 'the URL ends with /view/<boxName>', (done) ->
      wd40.trueURL (err, result) ->
        result.should.match /\/view\/(\w+)$/
        done()

    it 'the iframe hash includes settings for both a source and a target', =>
      should.exist @settingsHash.source
      should.exist @settingsHash.target
      Object.keys(@settingsHash).should.have.length 2

    it 'iframe hash includes a target box name', =>
      should.exist @settingsHash.target.box

    it 'the iframe hash does not include a target apikey', =>
      should.not.exist @settingsHash.target.apikey

    it 'the iframe hash includes a target box url', =>
      should.exist @settingsHash.target.url

    it 'the target box url is on the free server', =>
      @settingsHash.target.url.should.match /^http:\/\/free-server/

    it 'iframe hash includes a source box name', =>
      should.exist @settingsHash.source.box

    it 'the iframe hash includes a source apikey', =>
      should.exist @settingsHash.source.apikey

    it 'the iframe hash includes a source box url', =>
      should.exist @settingsHash.source.url

    it 'the source box url is on the paid server', =>
      @settingsHash.source.url.should.match /^http:\/\/medium-server/

