_ = require 'underscore'
request = require 'request'
should = require 'should'
async = require 'async'

settings = require '../settings.json'
serverURL = process.env.CU_TEST_SERVER or settings.serverURL

describe 'Server-side rendering', ->
  before ->
    @toolName = "int-test-#{String(Math.random()*Math.pow(2,32))[0..6]}"

  context "When I scrape the homepage with javascript off", ->
    before (done) ->
      request.get
        uri: serverURL
      , (err, res, body) =>
        @body = body
        done()

    it 'I see homepage HTML content', ->
      @body.should.match /<div class="hero-unit">/gi

    it 'I see the nav bar content', ->
      @body.should.match /<a href="\/professional">/gi

  context "When I scrape the About page with javascript off", ->
    before (done) ->
      request.get
        uri: "#{serverURL}/about"
      , (err, res, body) =>
        @body = body
        done()

    it 'I see About Page HTML content', ->
      @body.should.match /<div class="hero-unit">/gi
      @body.should.match /<h2>our team/gi
      @body.should.match /company history/gi

  context "When I scrape the Professional Services page with javascript off", ->
    before (done) ->
      request.get
        uri: "#{serverURL}/professional"
      , (err, res, body) =>
        @body = body
        done()

    it 'I see Professional Services HTML content', ->
      @body.should.match /ScraperWiki is a place where data professionals/gi

    it 'I see case studies', ->
      @body.should.match /UK Government Digital Services/gi
      @body.should.match /Channel 4 Dispatches/gi
      @body.should.match /NewsReader/gi
      @body.should.match /GCloud/gi
      @body.should.match /FP7/gi
