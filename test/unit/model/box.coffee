mongoose = require 'mongoose'
sinon = require 'sinon'
should = require 'should'
_ = require 'underscore'
request = require 'request'

{Box} = require 'model/box'

describe 'Box (server)', ->
  firstBox = null
  before ->
    sinon.stub request, 'post', (opts_, cb) -> cb null, statusCode: 200, "{}"
    mongoose.connect process.env.CU_DB unless mongoose.connection.db

  after ->
    request.post.restore()

  context 'when adding a new box', ->
    before (done) ->
      Box.create
        shortName: 'testofferson'
        accountLevel: 'grandfather'
      , (err, box) =>
        firstBox = box
        done err

    it 'assigns a random uid', ->
      should.exist firstBox.uid
      firstBox.uid.should.be.within 4000, 429496729

  context 'when there is a uid collision', ->
    before (done) ->
      returnedOneFake = Boolean(false)

      testUid = =>
        if returnedOneFake is true
          return 324234324234
        else
          returnedOneFake = true
          return firstBox.uid

      sinon.stub Box, 'generateUid', testUid

      Box.create
        shortName: 'testofferson'
        accountLevel: 'grandfather'
      , (err, box) =>
        @secondBox = box
        done()

    it "doesn't break, and assigns another random value", ->
      should.exist @secondBox.uid
      @secondBox.uid.should.not.equal firstBox.uid
