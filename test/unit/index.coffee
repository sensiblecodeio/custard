should = require 'should'
request = require 'supertest'
sinon = require 'sinon'

delete process.env['NODETIME_KEY']

index = require '../../server/code/index'
{Dataset} = require '../../server/code/model/dataset'
app = index.app


describe 'Express Routes', ->
  it '/pricing/', (done) ->
    request(app)
      .get('/terms/')
      .expect(200)
      .expect(/Pricing/)
      .end(done)

  it '/signup/freetrial/', (done) ->
    request(app)
      .get('/signup/freetrial/')
      .expect(200)
      #.expect(/Free Trial/)
      .expect(/Create Account/)
      .end(done)

  it '/signup/datascientist/', (done) ->
    request(app)
      .get('/signup/datascientist/')
      .expect(200)
      #.expect(/Datascientist/)
      .expect(/Create Account/)
      .end(done)

  it '/signup/exporer/', (done) ->
    request(app)
      .get('/signup/explorer/')
      .expect(200)
      #.expect(/Explorer/)
      .expect(/Create Account/)
      .end(done)

  it '/help/', (done) ->
    request(app)
      .get('/help/')
      .expect(200)
      .expect(/General help/)
      .expect(/Quick start guides/)
      .expect(/Reference documentation/)
      .end(done)

  it '/terms/', (done) ->
    request(app)
      .get('/terms/')
      .expect(200)
      .expect(/Terms &amp; Conditions/)
      .end(done)

  it '/terms/enterprise-agreement/', (done) ->
    request(app)
      .get('/terms/enterprise-agreement/')
      .expect(200)
      .expect(/ScraperWiki Enterprise Agreement/)
      .end(done)

  it '/', (done) ->
    request(app)
      .get('/')
      .expect(200)
      .expect(/placeholder for the internal home page/)
      .end(done)

  it '/login/', (done) ->
    request(app)
      .get('/login/')
      .expect(200)
      .expect(/Log in/)
      .expect(/Username:/)
      .expect(/Password:/)
      .end(done)

describe 'Error Handling', ->
  it 'Should display a 404 error', (done) ->
    request(app)
      .get('/xxsdsdsdsd')
      .expect(404)
      .expect(/Not found/)
      .end(done)

describe "Status End Point", ->
  xit 'Should set the status of the dataset', (done) ->
    spy = sinon.spy(Dataset, 'findOneById')
    request(app)
      .post('/api/status/')
      .end (err, res) ->
        (spy.calledWith process.env['USER']).should.be.true
        done()


