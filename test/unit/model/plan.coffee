sinon = require 'sinon'
should = require 'should'
_ = require 'underscore'
request = require 'request'

plan = require('model/plan')
Box = require('model/box')()

describe 'Plan (Server)', ->
  describe 'Can get maximum box size', ->
    it 'gets 8Mb for the free plan', ->
      plan.boxMaxSize("free").should.equal 8

  describe 'Can set quota of a box', ->
    class TestDb
      save: (callback) ->
        callback null
    Dataset = require('model/dataset').dbInject TestDb

    before (done) ->
      @request = sinon.stub request, 'post', (opt, cb) ->
        cb null, null, null

      box = new Box
        users: ['freetard']
        name: 'ehaf921'

      plan.setDiskQuota box, 'free', done
    
    it 'made the right HTTP request to change glusterfs quota', ->
      correctArgs = @request.calledWith
        uri: "#{process.env.CU_QUOTA_SERVER}/quota"
        form:
          path: 'ehaf921'
          size: 8
      correctArgs.should.be.true

