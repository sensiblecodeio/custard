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
        accountLevel: 'grandfather-ec2'
      , (err, box) =>
        firstBox = box
        done err

    it 'assigns a random uid', ->
      should.exist firstBox.uid
      firstBox.uid.should.be.within 4000, 429496729

  context 'when there is a uid collision', ->
    before (done) ->
      returnedOneFake = false

      testUid = =>
        if returnedOneFake
          res =  324234324234
        else
          returnedOneFake = true
          res = firstBox.uid
        return res

      sinon.stub Box, 'generateUid', testUid

      Box.create
        shortName: 'testofferson'
        accountLevel: 'grandfather-ec2'
      , (err, box) =>
        @secondBox = box
        done()

    after ->
      Box.generateUid.restore()

    it "doesn't break, and assigns another random value", ->
      should.exist @secondBox.uid
      @secondBox.uid.should.not.equal firstBox.uid

  context 'when a box has been given a uid', ->
    before (done) ->
      firstBox.server = 'bob.scraperwiki.com'
      firstBox.save done

    before (done) ->
      Box.findOneByName firstBox.name, (err, box) =>
        @sameBox = box
        done()

    it "doesn't change its uid", ->
      @sameBox.uid.should.equal firstBox.uid

  context 'when I call Box.listServers', ->
    before -> @servers = Box.listServers()

    it 'returns an array of all the box servers', ->
      @servers.should.include 'premium.scraperwiki.com'
      @servers.should.include 'free-ec2.scraperwiki.com'
      @servers.should.include 'ds-ec2.scraperwiki.com'

    it 'gives me three servers (because that is how many there currently are)', ->
      @servers.length.should.equal 4
