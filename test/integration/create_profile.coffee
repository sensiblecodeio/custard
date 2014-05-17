require './setup_teardown'
should = require 'should'
{wd40, browser, loginAndGo} = require './helper'

mongoose = require 'mongoose'
{User} = require 'model/user'

# Overview
# Login as teststaff and use the staff-only /create-profile page
# to create a few new user profiles.


before ->
  mongoose.connect process.env.CU_DB unless mongoose.connection.db

checkPasswordLink = (done) ->
  wd40.waitForText 'They can set their password here:', ->
    wd40.elementByCss '#password-reset-link', (err, element) ->
      element.getValue (err, value) ->
        value.should.match /^https?:\/\/.+\/set-password\/.+$/
        done()

describe 'Create a normal user', ->

  before (done) ->
    loginAndGo 'teststaff', process.env.CU_TEST_STAFF_PASSWORD, "/create-profile", done

  context 'When I enter new user details', ->
    before (done) ->
      wd40.click 'option[value="free-trial"]', ->
        wd40.fill '#displayname', 'John Smith', ->
          wd40.fill '#email', 'john@example.com', done

    it 'it autocompletes the shortName', (done) ->
      wd40.elementByCss '#shortname', (err, element) ->
        element.getValue (err, value) ->
          value.should.equal 'johnsmith'
          done()

    context 'When I submit the form', (done) ->
      before (done) ->
        wd40.click '#create-profile', done

      it 'it gives me a link where the user can set their password', checkPasswordLink

      it 'it has saved the right user details to the database', (done) ->
        User.findByShortName 'johnsmith', (err, user) =>
          should.exist user
          user.displayName.should.equal 'John Smith'
          user.email.should.eql ['john@example.com']
          done()


describe 'Create a user in a corporate datahub', ->

  before (done) ->
    loginAndGo 'teststaff', process.env.CU_TEST_STAFF_PASSWORD, "/create-profile", done

  context 'When I enter new user details, and select a default data hub', ->
    before (done) ->
      wd40.click 'option[value="free-trial"]', ->
        wd40.fill '#displayname', 'John Smith the second', ->
          wd40.fill '#email', 'john@example.com', ->
            wd40.fill '#defaultcontext', 'testersonltd', ->
              wd40.click '#create-profile', ->
                done()

    it 'it gives me a link where the user can set their password', checkPasswordLink

    it 'it has saved the right user details to the database', (done) ->
      User.findByShortName 'johnsmiththesecond', (err, user) =>
        should.exist user
        user.displayName.should.equal 'John Smith the second'
        user.email.should.eql ['john@example.com']
        user.should.have.property 'defaultContext'
        user.defaultContext.should.equal 'testersonltd'
        user.canBeReally.should.be.empty
        done()

    it 'it has put the new user into the corporate datahub', (done) ->
      User.findByShortName 'testersonltd', (err, company) =>
        company.canBeReally.should.include 'johnsmiththesecond'
        done()
