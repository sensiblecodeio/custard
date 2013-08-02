cleanCrontab = require process.cwd() + '/bin/clean_crontabs' 
dataset = require 'model/dataset'
sinon = require 'sinon'

class MockDb
  @results: [{cleanCrontab: ->}, {cleanCrontab: ->}]
  @findToBeDeleted: (callback) ->
    callback null, @results

describe "clean_crontabs", ->
  it "calls clean_crontab on each overdue dataset", ->
    spy1 = sinon.spy(MockDb.results[0], 'cleanCrontab')
    spy2 = sinon.spy(MockDb.results[1], 'cleanCrontab')

    cleanCrontab.main(MockDb)

    spy1.called.should.be.true
    spy2.called.should.be.true
