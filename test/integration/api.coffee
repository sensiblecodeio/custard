request = require 'superagent'
should = require 'should'
settings = require '../settings.json'

describe 'API', ->
  before ->
    @user = 'ickletest'
    @password = 'toottoot'
    @loginURL = "#{settings.serverURL}/login"

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
