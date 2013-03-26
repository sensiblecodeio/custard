sinon = require 'sinon'
should = require 'should'
_ = require 'underscore'
request = require 'request'

plan = require('model/plan')

describe 'Plan (Server)', ->
  describe 'Can get maximum dataset size', ->
    it 'gets 8Mb for the free plan', ->
      plan.datasetMaxSize("free").should.equal 8

  describe 'Can set quota of a dataset', ->
    class TestDb
      save: (callback) ->
        callback null
    Dataset = require('model/dataset').dbInject TestDb

    before (done) ->
      @request = sinon.stub request, 'post', (opt, cb) ->
        cb null, null, null

      @dataset = new Dataset
        box: 'fskjh33i'
        tool: 'mooble-tool'
        displayName: 'Test dataset'

      plan.setDiskQuota @dataset, 'free', done
    
    it 'made the right HTTP request to change glusterfs quota', ->
      correctArgs = @request.calledWith
        uri: "#{process.env.CU_QUOTA_SERVER}/quota"
        form:
          path: 'fskjh33i'
          size: 8

