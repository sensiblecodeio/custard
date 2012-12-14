request = require 'request'
should = require 'should'
settings = require '../settings.json'

describe 'API', ->
  before ->
    @user = 'ickletest'
    @datasetId = ''

  describe 'Datasets', ->
    context 'GET: /api/:user/datasets', ->
      it 'returns a list of datasets'

    context 'GET /api/:user/datasets/:id', ->
      it 'returns a single dataset'
      it "500 errors if it doesn't exist"

    context 'POST /api/:user/datasets', ->
      it 'creates a new dataset'
      it 'returns the newly created dataset'

    context 'PUT /api/:user/datasets/:id', ->
      it 'updates a single dataset with new values'
      it "500 errors if it doesn't exist"
