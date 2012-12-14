request = require 'superagent'
should = require 'should'
settings = require '../settings.json'

describe 'API', ->
  before (done) ->
    @password = 'toottoot'
    @loginURL = "#{settings.serverURL}/login"
    @agent = request.agent()
    @agent.post(@loginURL)
      .send({ user: @user, password: @password })
      .end (err, res) ->
        done(err)

  describe 'Datasets', ->
    context 'when I create a dataset', ->
      before ->
        @dataset = null

      context 'POST /api/:user/datasets', ->
        it 'creates a new dataset'
        it 'returns the newly created dataset'

      context 'GET: /api/:user/datasets', ->
        it 'returns a list of datasets'

      context 'GET /api/:user/datasets/:id', ->
        it 'returns a single dataset'
        it "500 errors if it doesn't exist"

      context 'PUT /api/:user/datasets/:id', ->
        it 'updates a single dataset with new values'
        it "500 errors if it doesn't exist"



