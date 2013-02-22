request = require 'request'
should = require 'should'
settings = require '../settings.json'

serverURL = process.env.CU_TEST_SERVER or settings.serverURL

describe 'API', ->
  context "When I'm logged in", ->
    before (done) ->
      @token = '339231725782156'
      @user = 'ickletest'
      @password = 'toottoot'
      @fullName = 'Mr Ickle Test'

      # Set password & login
      request.post
        uri: "#{serverURL}/api/token/#{@token}"
        form:
          password: @password
      , (err, res) =>
        @loginURL = "#{serverURL}/login"
        request.get @loginURL, =>
          request.post
            uri: @loginURL
            form:
              username: @user
              password: @password
          , (err, res) =>
            @loginResponse = res
            done(err)

    it 'managed to log in', ->
      should.exist @loginResponse
      # check we're being redirected to /, as opposed to /login
      @loginResponse.body.should.include 'Redirecting to /'
      @loginResponse.body.should.not.include 'Redirecting to /login'

    describe 'Tools', ->
      context 'POST /api/tools', ->
        before ->
          @toolName = "int-test-#{String(Math.random()*Math.pow(2,32))[0..6]}"
        context 'when I create a tool', ->
          before (done) ->
            request.post
              uri: "#{serverURL}/api/tools"
              form:
                name: @toolName
                type: 'view'
                gitUrl: 'git://github.com/scraperwiki/spreadsheet-tool.git'
            , (err, res) =>
              @response = res
              @tool = JSON.parse res.body
              done()

          it 'creates a new tool', ->
            @response.should.have.status 201

          it 'returns the newly created tool', ->
            should.exist @tool.name
            @tool.name.should.equal @toolName

        context 'when I update a tool', ->
          before (done) ->
            request.post
              uri: "#{serverURL}/api/tools"
              form:
                name: @toolName
                type: 'view'
                gitUrl: 'git://github.com/scraperwiki/spreadsheet-tool.git'
            , (err, res) =>
              @response = res
              @tool = JSON.parse res.body
              done()

          it 'updates the tool', ->
            @response.should.have.status 200

          # We should check whether the manifest has been updated,
          # but it's hard.
          xit 'returns the updated tool', ->
            @tool.manifest.displayName.should.equal 'View Data 2'

          it "doesn't allow me to update the type"

      context 'GET /api/tools', ->
        before (done) ->
          request.get "#{serverURL}/api/tools", (err, res) =>
            @body = res.body
            done()

        it 'returns a list of tools', ->
          tools = JSON.parse @body
          tools.length.should.be.above 0

        it 'returns the right fields', ->
          tools = JSON.parse @body
          should.exist tools[0].name
          should.exist tools[0].gitUrl
          should.exist tools[0].type

    describe 'Datasets', ->
      context 'when I create a dataset', ->
        response = null
        dataset = null

        before (done) ->
          request.post
            uri: "#{serverURL}/api/#{@user}/datasets"
            form:
              displayName: 'Biscuit'
              box: String(Math.random() * Math.pow(2, 32))
          , (err, res) ->
            response = res
            dataset = JSON.parse res.body
            done()

        context 'POST /api/:user/datasets', ->
          it 'creates a new dataset', ->
            response.should.have.status 200

          it 'returns the newly created dataset', ->
            should.exist dataset.box
            dataset.displayName.should.equal 'Biscuit'

        context 'GET /api/:user/datasets/:id', ->
          it 'returns a single dataset', (done)  ->
            request.get "#{serverURL}/api/#{@user}/datasets/#{dataset.box}", (err, res) ->
              dataset = JSON.parse res.body
              should.exist dataset.box
              done()

          it "404 errors if the dataset doesn't exist", (done) ->
            request.get "#{serverURL}/api/#{@user}/datasets/NOTEXIST", (err, res) ->
              res.should.have.status 404
              done()

          it "403 errors if the user doesn't exist", (done) ->
            request.get "#{serverURL}/api/MRINVISIBLE/datasets/#{dataset.box}", (err, res) ->
              res.should.have.status 403
              done()

        context 'PUT /api/:user/datasets/:id', ->
          it 'changes the display name of a single dataset', (done) ->
            request.put
              uri: "#{serverURL}/api/#{@user}/datasets/#{dataset.box}"
              form:
                displayName: 'Cheese'
            , (err, res) =>
              res.should.have.status 200
              request.get "#{serverURL}/api/#{@user}/datasets/#{dataset.box}", (err, res) ->
                dataset = JSON.parse res.body
                dataset.displayName.should.equal 'Cheese'
                done(err)

          it 'changes the owner of a single dataset', (done) ->
            @newowner = 'ehg'
            request.put
              uri: "#{serverURL}/api/#{@user}/datasets/#{dataset.box}"
              form:
                user: @newowner
            , (err, res) =>
              res.should.have.status 200
              done(err)

          it "that dataset doesn't appear in my list of datasets any more", (done) ->
            request.get "#{serverURL}/api/#{@user}/datasets", (err, res) ->
              res.body.should.not.include "#{dataset.box}"
              done()

          it "404 errors if the dataset doesn't exist", (done) ->
            request.put "#{serverURL}/api/#{@user}/datasets/NOTEXIST", (err, res) ->
              res.should.have.status 404
              done()

      context 'GET: /api/:user/datasets', ->
        it 'returns a list of datasets', (done) ->
          request.get "#{serverURL}/api/#{@user}/datasets", (err, res) ->
            datasets = JSON.parse res.body
            datasets.length.should.be.above 0
            done err

      context 'POST: /api/:user/sshkeys', ->
        it 'returns ok', (done) ->
          request.post
            uri: "#{serverURL}/api/#{@user}/sshkeys"
            form:
              key: 'key'
          , (err, res) ->
            res.body.should.include 'ok'
            done err

    describe 'Users', ->
      context "When I'm a staff member", ->
        before (done) ->
          # logout
          request.get "#{serverURL}/logout", done
        before (done) ->
          @loginURL = "#{serverURL}/login"
          @user = "teststaff"
          @password = process.env.CU_TEST_STAFF_PASSWORD
          request.get @loginURL, =>
            request.post
              uri: @loginURL
              form:
                username: @user
                password: @password
            , (err, res) =>
              @loginResponse = res
              done(err)
        it 'allows me to create a new profile', (done) ->
          @newUser = "new-#{String(Math.random()*Math.pow(2,32))[0..6]}"
          @newPassword = "newpass"
          request.post
            uri: "#{serverURL}/api/#{@newUser}"
            form:
              email: 'random@example.com'
              displayName: 'Ran Dom Test'
          , (err, resp, body) =>
            obj = JSON.parse body
            @token = obj.token
            resp.should.have.status 201
            done(err)
        it '... and I can set the password', (done) ->
          request.post
            uri: "#{serverURL}/api/token/#{@token}"
            form:
              password: @newPassword
          , (err, resp, body) ->
            resp.should.have.status 200
            done(err)
