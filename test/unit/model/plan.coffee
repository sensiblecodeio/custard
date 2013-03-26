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

  xdescribe 'Can set quota of a box', ->
    class TestDb
      save: (callback) ->
        callback null
    Dataset = require('model/dataset').dbInject TestDb

    before (done) ->
      @request = sinon.stub request, 'post', (opt, cb) ->
        cb null, null, null
      console.log Box.findAllByUser

      Box.findAllByUser 'ehg', done
      (err, boxes) =>
        console.log "boxes #{boxes}"
        @box = boxes[0]
        plan.setDiskQuota box, 'free', done
    
    it 'made the right HTTP request to change glusterfs quota', ->
      correctArgs = @request.calledWith
        uri: "#{process.env.CU_QUOTA_SERVER}/quota"
        form:
          path: @box.name
          size: 8
      correctArgs.should.be.true

