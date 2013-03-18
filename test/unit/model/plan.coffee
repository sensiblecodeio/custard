sinon = require 'sinon'
should = require 'should'
_ = require 'underscore'

request = require 'request'

plan = require('model/plan')

describe 'Plan (Server)', ->
  describe 'Can get maximum dataset size', ->
    it 'gets 8Mb for the free plan', ->
      plan.datasetMaxSize("free").should.equal 8

    #  describe 'Can set quota of a dataset', ->
    #before (done) ->
    #  plan.setDiskQuota()
    #
    #xit '', ->
    #  #
