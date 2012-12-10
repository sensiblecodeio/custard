sinon = require 'sinon'
should = require 'should'
helper = require '../helper'

helper.evalConcatenatedFile 'client/code/app.coffee'

describe 'Client model: Dataset', ->
  describe 'URL', ->

    beforeEach ->

      @dataset = new Cu.Model.Dataset(user: 'test')

    it 'has an URL of /api/test/datasets/{id} if the dataset has an id', ->
      @dataset.set _id: '324234fsjhdfs384238'
      @dataset.url().should.equal '/api/test/datasets/324234fsjhdfs384238'

    it 'has an URL of /api/test/datasets if the dataset has NO id', ->
      @dataset.url().should.equal '/api/test/datasets'

describe 'Server model: Dataset', ->
  Dataset = require 'model/dataset'

  before ->
    @dataset = new Dataset()

  it 'has a save method', ->
    should.exist @dataset.save

