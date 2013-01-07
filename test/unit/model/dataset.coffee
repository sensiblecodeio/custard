sinon = require 'sinon'
should = require 'should'
helper = require '../helper'

helper.evalConcatenatedFile 'client/code/app.coffee'

describe 'Client model: Dataset', ->
  describe 'URL', ->
    beforeEach ->
      @boxName = 'blah'
      @dataset = new Cu.Model.Dataset {user: 'test', box: @boxName}

    it 'has an URL of /api/test/datasets/{id} if the dataset is new', ->
      @dataset.new = true
      @dataset.url().should.equal '/api/test/datasets'

    it 'has an URL of /api/test/datasets if the dataset is not new', ->
      @dataset.url().should.include @boxName

describe 'Server model: Dataset', ->
  Dataset = require 'model/dataset'

  before ->
    @dataset = new Dataset()

  it 'has a save method', ->
    should.exist @dataset.save

