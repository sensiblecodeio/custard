request = require 'request'
should = require 'should'
settings = require '../settings.json'

describe 'API', ->
  before (done) ->
    @user = 'ickletest'
    @password = 'toottoot'
    @fullName = 'Mr Ickle Test'

    @loginURL = "#{settings.serverURL}/login"
    @agent = request
    @agent.get @loginURL, =>
      @agent.post
        uri: @loginURL
        form:
          username: @user
          password: @password
      , (err, res) =>
          @loginResponse = res
          #console.log(res)
          done(err)

  it 'managed to log in', ->
    should.exist @loginResponse
    # check we're being redirected to /, as opposed to /login
    @loginResponse.body.should.include 'Redirecting to /'
    @loginResponse.body.should.not.include 'Redirecting to /login'

  describe 'Datasets', ->
    context 'when I create a dataset', ->
      before ->
        @dataset = null

      context 'POST /api/:user/datasets', ->
        it 'creates a new dataset'
        it 'returns the newly created dataset'

      context 'GET: /api/:user/datasets', ->
        it 'returns a list of datasets', (done) ->
          @agent.get "#{settings.serverURL}/api/#{@user}/datasets", (err, res) ->
            datasets = JSON.parse res.body
            datasets.length.should.be.above 1
            done(err)

      context 'GET /api/:user/datasets/:id', ->
        it 'returns a single dataset'
        it "500 errors if it doesn't exist"

      context 'PUT /api/:user/datasets/:id', ->
        it 'updates a single dataset with new values'
        it "500 errors if it doesn't exist"



