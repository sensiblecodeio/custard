request = require 'superagent'
should = require 'should'
settings = require '../settings.json'

describe 'API', ->
  before (done) ->
    @user = 'ickletest'
    @password = 'toottoot'
    @fullName = 'Mr Ickle Test'

    @loginURL = "#{settings.serverURL}/login"
    @agent = request.agent()
    @agent.get @loginURL, =>
      @agent.post(@loginURL)
        .send({ user: @user, password: @password })
        .end (err, res) =>
          @loginResponse = res
          #console.log(res)
          done(err)

  it 'managed to log in', ->
    should.exist @loginResponse
    # check for the menu at the top right with their name in it
    @loginResponse.text.should.include @fullName

  describe 'Datasets', ->
    context 'when I create a dataset', ->
      before ->
        @dataset = null

      context 'POST /api/:user/datasets', ->
        it 'creates a new dataset'
        it 'returns the newly created dataset'

      context 'GET: /api/:user/datasets', ->
        it 'returns a list of datasets', (done) ->
          @agent.get("/api/#{@user}/datasets")
            .end (err, res) ->
              #console.log res
              #console.log res.body
              done(err)

      context 'GET /api/:user/datasets/:id', ->
        it 'returns a single dataset'
        it "500 errors if it doesn't exist"

      context 'PUT /api/:user/datasets/:id', ->
        it 'updates a single dataset with new values'
        it "500 errors if it doesn't exist"



