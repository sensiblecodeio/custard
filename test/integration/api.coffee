net = require 'net'
helper = require './helper'

_ = require 'underscore'
request = require 'request'
should = require 'should'
async = require 'async'
redis = require 'redis'

settings = require '../settings.json'
serverURL = process.env.CU_TEST_SERVER or settings.serverURL

# Timeout period in milliseconds for duplicate request
# debouncing. (see underscore debounce and test that uses these)
DEBOUNCE_PERIOD = 1000
EPSILON = 100

login = (done) ->
  @loginURL = "#{serverURL}/login"
  request.get
    uri: "#{serverURL}/logout"
    followRedirect: false
  , (err) =>
    request.get @loginURL, =>
      request.post
        uri: @loginURL
        form:
          username: @user
          password: @password
      , (err, res) =>
        @loginResponse = res
        done(err)

describe 'API', ->
  before ->
    @toolName = "int-test-#{String(Math.random()*Math.pow(2,32))[0..6]}"
  context "When I'm not logged in", ->

    describe 'Data request form', ->
      context 'POST /api/data-request', ->
        before (done) ->
          request.post
            uri: "#{serverURL}/api/data-request/"
            form:
              name: 'Steve Jobs'
              phone: '1-800-MY-APPLE'
              email: 'stevejobs@sharklasers.com'
              description: 'Need data for thermonuclear war against android. Pls help. Kthxbai.'
          , (err, res, body) =>
            @body = JSON.parse(body)
            done()

        it 'returns a valid ticket ID', ->
          @body.should.have.property 'id'
          1999.should.be.below @body.id

    describe 'Data request form (invalid request)', ->
      context 'POST /api/data-request', ->
        before (done) ->
          request.post
            uri: "#{serverURL}/api/data-request/"
            form:
              name: 'Steve Jobs'
              email: 'steve'
              description: 'Need data for thermonuclear war against android. Pls help. Kthxbai.'
          , (err, res, body) =>
            @body = body
            @res = res
            done()

        it 'response has a 500 status', ->
          @res.should.have.status 500

        it 'response should include an error message', ->
          @body.should.include "Please tell us your email address"

    describe 'Sign up', ->
      context 'POST /api/<username>', ->
        before (done) ->
          request.post
            uri: "#{serverURL}/api/user/"
            form:
              shortName: 'tabbytest'
              displayName: 'Tabatha Testerson'
              email: 'tabby@example.org'
              inviteCode: process.env.CU_INVITE_CODE
              acceptedTerms: 1
          , (err, res, body) =>
            @body = body
            done()

        it 'returns ok', ->
          @body.should.include 'tabbytest'

  context "When I have set my password", ->
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
      , done

    describe 'Tools', ->
      context 'POST /api/tools', ->
        context 'when I create a tool (without specifying privacy)', ->
          before (done) ->
            request.post
              uri: "#{serverURL}/api/tools"
              form:
                name: @toolName
                type: 'view'
                gitUrl: 'git://github.com/scraperwiki/spreadsheet-tool.git'
            , (err, res, body) =>
              @response = res
              @tool = JSON.parse res.body
              done()

          it 'creates a new tool', ->
            @response.should.have.status 201

          it 'records a "created" timestamp', ->
            should.exist @tool.created

          it 'records the owner', ->
            should.exist @tool.user

          it 'returns the newly created tool', ->
            should.exist @tool.name
            @tool.name.should.equal @toolName

          it 'is owned by me', ->
            @user.should.equal @tool.user

          it 'is private', ->
            @tool.public.should.be.false

          context 'when I update that tool', ->
            before (done) ->
              # short pause, to make sure the updated
              # timestamp is after the created one
              setTimeout done, 1

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

            it 'is still private', ->
              @tool.public.should.be.false

            it 'shows a recent "updated" timestamp', ->
              should.exist @tool.created
              should.exist @tool.updated
              @tool.updated.should.be.above @tool.created

            # We should check whether the manifest has been updated,
            # but it's hard.
            xit 'returns the updated tool', ->
              @tool.manifest.displayName.should.equal 'View Data 2'

        context 'When I create a private tool', ->
          before (done) ->
            request.post
              uri: "#{serverURL}/api/tools"
              form:
                name: "#{@toolName}-private"
                type: 'view'
                gitUrl: 'git://github.com/scraperwiki/test-app-tool.git'
                public: false
            , (err, res, body) =>
              @response = res
              @tool = JSON.parse res.body
              done()

          it 'creates a new tool', ->
            @response.should.have.status 201

          it 'is private', ->
            @tool.public.should.be.false

        context 'When I create a public tool', ->
          before (done) ->
            request.post
              uri: "#{serverURL}/api/tools"
              form:
                name: "#{@toolName}-public"
                type: 'view'
                gitUrl: 'git://github.com/scraperwiki/test-app-tool.git'
                public: true
            , (err, res, body) =>
              @response = res
              @tool = JSON.parse res.body
              done()

          it 'creates a new tool', ->
            @response.should.have.status 201

          it 'is public', ->
            @tool.public.should.be.true

      context 'GET /api/tools', ->
        before (done) ->
          request.get "#{serverURL}/api/tools", (err, res) =>
            @body = res.body
            @tools = JSON.parse @body
            done()

        it 'returns a list of tools', ->
          @tools.length.should.be.above 0

        it "includes my first tool", ->
          should.exist(_.find @tools, (x) => x.name == @toolName)

        it "includes my private tool", ->
          should.exist(_.find @tools, (x) => x.name == "#{@toolName}-private")

        it "includes my public tool", ->
          should.exist(_.find @tools, (x) => x.name == "#{@toolName}-public")

        it "includes public tools", ->
          should.exist(_.find @tools, (x) => x.name == "test-app")

        it 'returns the right fields', ->
          should.exist @tools[0].name
          should.exist @tools[0].gitUrl
          should.exist @tools[0].type

    describe 'Datasets', ->
      context 'when I create a dataset', ->

        createDatasets = (number, opts, callback) ->
          functionArr = []
          callback = opts unless arguments[2]?
          for i in [1..number]
            functionArr.push (cb) =>
              random = String(Math.random()*Math.pow(2,32))[0..4]
              request.post
                uri: "#{serverURL}/api/#{opts.user or 'ickletest'}/datasets"
                form:
                  displayName: opts.displayName or "Dataset #{random}"
                  tool: opts.tool or 'test-app'
              , cb

          async.series functionArr, (err, res) ->
            if res.length is 1
              callback err, res[0][0], res[0][1]
            else
              callback res

        before (done) ->
          createDatasets 1,
            displayName: 'Biscuit'
            tool: 'test-app'
            user: @user
          , (err, res, body) =>
            @response = res
            @dataset = JSON.parse res.body
            done()

        context 'POST /api/:user/datasets', ->
          it 'creates a new dataset', ->
            @response.should.have.status 200

          it 'returns the newly created dataset', ->
            should.exist @dataset.box
            @dataset.displayName.should.equal 'Biscuit'

          it 'has an associated boxServer...', ->
            should.exist @dataset.boxServer

        context 'GET /api/:user/datasets/:id', ->
          it 'returns a single dataset', (done)  ->
            request.get "#{serverURL}/api/#{@user}/datasets/#{@dataset.box}", (err, res) ->
              newDataset = JSON.parse res.body
              should.exist newDataset.box
              done()

          it 'dataset has a created date', (done)  ->
            request.get "#{serverURL}/api/#{@user}/datasets/#{@dataset.box}", (err, res) ->
              newDataset = JSON.parse res.body
              Date.parse(newDataset.createdDate).should.be.above(0)
              done()

          it 'dataset has a creator short name', (done)  ->
            request.get "#{serverURL}/api/#{@user}/datasets/#{@dataset.box}", (err, res) ->
              newDataset = JSON.parse res.body
              newDataset.creatorShortName.should.equal 'ickletest'
              done()

          it 'dataset has a creator display name', (done)  ->
            request.get "#{serverURL}/api/#{@user}/datasets/#{@dataset.box}", (err, res) ->
              newDataset = JSON.parse res.body
              newDataset.creatorDisplayName.should.equal 'Ickle Test'
              done()

          it "404 errors if the dataset doesn't exist", (done) ->
            request.get "#{serverURL}/api/#{@user}/datasets/NOTEXIST", (err, res) ->
              res.should.have.status 404
              done()

          it "403 errors if the user doesn't exist", (done) ->
            request.get "#{serverURL}/api/MRINVISIBLE/datasets/#{@dataset.box}", (err, res) ->
              res.should.have.status 403
              done()

          context 'I create some more', ->
            before (done) ->
              createDatasets 2, ->
                done()

            it "doesn't let me create the 4th one", (done) ->
              createDatasets 1, (err, res, body) ->
                res.should.have.status 402
                done()

           context "I try to create a dataset with a tool I don't have access to", ->
             before (done) ->
               createDatasets 1,
                 displayName: 'BADMAN'
                 tool: 'private-tool'
                 user: @user
               , (err, res, body) =>
                 @response = res
                 done()

             it "doesn't let me create the dataset", ->
               @response.should.have.status 402

        describe 'Views', ->
          context 'when I create a view on a dataset', ->
            before (done) ->
              request.post
                uri: "#{serverURL}/api/#{@user}/datasets/#{@dataset.box}/views"
                form:
                  name: 'carrottop'
                  displayName: 'Carrot Top'
                  tool: 'test-plugin'
              , (err, res, body) =>
                @response = res
                @view = JSON.parse res.body
                done()

            context 'POST /api/:user/datasets/<dataset>/views', ->
              it 'creates a new dataset', ->
                @response.should.have.status 200

              it 'returns the newly created view', ->
                should.exist @view.box
                @view.displayName.should.equal 'Carrot Top'

              it 'has an associated boxServer...', ->
                should.exist @view.boxServer


        context 'PUT /api/:user/datasets/:id', ->
          it 'changes the display name of a single dataset', (done) ->
            request.put
              uri: "#{serverURL}/api/#{@user}/datasets/#{@dataset.box}"
              form:
                displayName: 'Cheese'
            , (err, res) =>
              res.should.have.status 200
              request.get "#{serverURL}/api/#{@user}/datasets/#{@dataset.box}", (err, res) =>
                @dataset = JSON.parse res.body
                @dataset.displayName.should.equal 'Cheese'
                done(err)

          it 'changes the owner of a single dataset', (done) ->
            @newowner = 'ehg'
            request.put
              uri: "#{serverURL}/api/#{@user}/datasets/#{@dataset.box}"
              form:
                user: @newowner
            , (err, res) =>
              res.should.have.status 200
              done(err)

          it "that dataset doesn't appear in my list of datasets any more", (done) ->
            request.get "#{serverURL}/api/#{@user}/datasets", (err, res) =>
              res.body.should.not.include "#{@dataset.box}"
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
              key: '  ssh-rsa AAAAB3NzaC1yc2EAAAAD...mRRu21YYMK7GSE7gZTtbI65WJfreqUY472s8HVIX foo@bar.local\n\n'
          , (err, res) ->
            res.body.should.include 'ok'
            done err

      context 'GET: /api/:user/sshkeys', ->
        it 'returns the key with whitespace trim', (done) ->
          request.get
            uri: "#{serverURL}/api/#{@user}/sshkeys"
          , (err, res) ->
            keys = JSON.parse res.body
            keys.should.include 'ssh-rsa AAAAB3NzaC1yc2EAAAAD...mRRu21YYMK7GSE7gZTtbI65WJfreqUY472s8HVIX foo@bar.local'
            done err

      context 'PUT: /api/user', ->
        it 'lets me accept the terms and conditions', (done) ->
          request.put
            uri: "#{serverURL}/api/user"
            form:
              acceptedTerms: 7
          , (err, res, body) =>
            res.should.have.status 200
            obj = JSON.parse body
            obj.acceptedTerms.should.equal 7
            done err

        it 'does not let me change my user name', (done) ->
          request.put
            uri: "#{serverURL}/api/user"
            form:
              shortName: 'zebadee'
          , (err, res) =>
            obj = JSON.parse res.body
            obj.shortName.should.not.equal 'zebadee'
            done err

        it 'does let me change my canBeReally field', (done) ->
          request.put
            uri: "#{serverURL}/api/user"
            form:
              canBeReally: ["test", "teststaff"]
            , (err, res) ->
              res.should.have.status 200
              obj = JSON.parse res.body
              obj.canBeReally.should.eql ['test', 'teststaff']
              done err

      context 'POST: /api/status', ->
        before (done) ->
          """Check that a local identd is running."""
          socket = net.connect 113, ->
            socket.end()
            done()
          socket.on 'error', (err) =>
            if /REFUS/.test err.code # ECONNREFUSED
              console.warn "          You are not running an identd locally, so this test won't work"
              @skip = true
            else
              throw err
            done()

        before (done) ->
          @redisClient = redis.createClient 6379, 'localhost'
          @redisClient.on 'psubscribe', -> done()
          @messagesReceived = 0
          @redisClient.on 'pmessage', (pattern, channel, message) =>
            @messagesReceived += 1

          @redisClient.psubscribe("*.cobalt.dataset.#{process.env.USER}.update")

        doRequest = (_, cb) ->
          request.post
            uri: "#{serverURL}/api/status"
            form:
              type: "ok"
              message: "just testing"
          , (err, res, body) ->
            # This relies on the fact that there is a box with
            # the same name as your userid. Add one to
            # fixtures.js if there isn't one already.
            res.should.have.status 200
            obj = JSON.parse body
            cb err

        it 'lets me POST to the status API endpoint (and is debounced)', (done) ->
          # Debounce meaning rate limit requests
          if @skip
            return done new Error "Skipped because no local identd"
          # Fire off 10 post requests (where only the last causes
          # redis activity)
          async.each [1..10], doRequest, (err) =>
            # Wait long enough for debounce and message to propagate
            setTimeout =>
              @messagesReceived.should.equal 1

              # Make another request and ensure that this one wasn't
              # culled by the debouncer
              doRequest "THIS PARAMETER NOT USED", =>
                setTimeout =>
                  @messagesReceived.should.equal 2
                  done()
                , DEBOUNCE_PERIOD + EPSILON
            , DEBOUNCE_PERIOD + EPSILON

    describe 'Billing', ->
      context 'GET /api/:user/subscription/medium/sign', ->
        before (done) ->
          request.get
            uri: "#{serverURL}/api/#{@user}/subscription/medium/sign"
          , (err, res, body) =>
            @body = body
            done err

        it 'returns a signature', ->
          @body.should.match /\w+|.+/g

        it 'returns the unsigned contents', ->
          @body.should.include 'subscription[plan_code]=medium'

      context 'POST /api/:user/subscription/verify', ->
        before (done) ->
          request.post
            uri: "#{serverURL}/api/#{@user}/subscription/verify"
            form:
              recurly_token: '34324sdfsdf'
          , (err, res, body) =>
            @res = res
            done err

        it 'returns a 404 (the token is unknown)', ->
          @res.should.have.status 404

  describe 'Switching', ->
    context 'POST /switch/ickletest', ->
      context "When ickletest has approved", ->
        before (done) ->
          # logout
          request.get "#{serverURL}/logout", done
        before (done) ->
          @loginURL = "#{serverURL}/login"
          @user = "test"
          @password = process.env.CU_TEST_PASSWORD
          request.get @loginURL, =>
            request.post
              uri: @loginURL
              form:
                username: @user
                password: "testing"
            , (err, res) =>
              @loginResponse = res
              done(err)

        it "can switch into ickletest's profile", (done) ->
          request.get
            uri: "#{serverURL}/switch/ickletest"
            followRedirect: false
          , (err, res) ->
            res.should.have.status 302
            done()

    context 'GET /api/user', ->
      before (done) ->
        request.get "#{serverURL}/api/user", (err, res, body) =>
          @body = body
          done()

      it 'gets ickletest and ehg as users test can switch into', ->
        @body.should.include 'ehg'
        @body.should.include 'ickletest'


  describe 'Forced context switch on login', ->
    context "When we login as tinat", ->
      before (done) ->
        @user = "tinat"
        @password = "testing"
        login.call @, done

      it 'forces me into the testersonltd context', (done) ->
        request.get "#{serverURL}/api/testersonltd/datasets", (err, res) ->
          res.should.have.status 200
          done err

    context "When we login as ehg", ->
      before (done) ->
        @user = "ehg"
        @password = "testing"
        login.call @, done

      it "doesn't force me into a different context", (done) ->
        request.get "#{serverURL}/api/ehg/datasets", (err, res) ->
          res.should.have.status 200
          done err

  describe "Automatic context switching", ->
    context "when I'm logged in as test", ->
      before (done) ->
        @user = 'test'
        @password = 'testing'
        login.call @, done

      context "when I visit ickletest's dataset", ->
        before (done) ->
          request.get "#{serverURL}/api/ickletest/datasets/3006375730", (err, res) =>
            @res = res
            done()

        it "I become ickletest and can look at ickletest's dataset", ->
          @res.should.have.status 200

  describe 'Logging in as a different user', ->
    context "When I'm a staff member", ->
      before (done) ->
        @user = 'teststaff'
        @password = process.env.CU_TEST_STAFF_PASSWORD
        login.call @, done

      before (done) ->
        request.get "#{serverURL}/api/tools", (err, res) =>
          @body = res.body
          @tools = JSON.parse @body
          done()

      it "does not see ickletest's first tool in tool list", ->
        should.not.exist(_.find @tools, (x) => x.name == @toolName)

      it "does not see ickletest's private tool in tool list", ->
        should.not.exist(_.find @tools, (x) => x.name == "#{@toolName}-private")

      it "does see ickletest's public tool in tool list", ->
        should.exist(_.find @tools, (x) => x.name == "#{@toolName}-public")

      it 'allows me to create a new profile', (done) ->
        @newUser = "new-#{String(Math.random()*Math.pow(2,32))[0..6]}"
        @newPassword = "newpass"
        request.post
          uri: "#{serverURL}/api/user"
          form:
            shortName: @newUser
            email: 'random@example.org'
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

  describe "Private tools", ->
    context 'When I add allowedUsers', ->
      before (done) ->
        request.post
          uri: "#{serverURL}/api/tools"
          form:
            name: "shared-private"
            type: 'view'
            gitUrl: 'git://github.com/scraperwiki/test-plugin-tool.git'
            public: false
            allowedUsers: ['test', 'ickletest']
        , (err, res, body) =>
          @response = res
          @tool = JSON.parse res.body
          done()

      it 'is shared with some users', ->
        @tool.allowedUsers.should.eql ['test', 'ickletest']

    context 'When I log in as test', ->
      before (done) ->
       @user = "test"
       @password = "testing"
       login.call @, done

      before (done) ->
        @toolsURL = "#{serverURL}/api/tools"
        request.get
          uri: @toolsURL,
        , (err, res, body) =>
          @tools = JSON.parse body
          done()

      it "includes the private tool", ->
        should.exist(_.find @tools, (x) => x.name == "shared-private")

  describe 'Upgrading my account', ->
    context "When I'm upgrading from medium to large", ->

      before (done) ->
        helper.mediumizeMary done

      context 'PUT /api/:user/subscription/change/large-ec2', ->
        before (done) ->
          @user = 'mediummary'
          @password = 'testing'
          login.call @, done

        before (done) ->
          request.put
            uri: "#{serverURL}/api/#{@user}/subscription/change/large-ec2"
          , (err, resp, body) =>
            @resp = resp
            done(err)

        it "returns a success", ->
          @resp.should.have.status 200

    context "When I'm downgrading from large to medium", ->
      context 'PUT /api/:user/subscription/change/medium-ec2', ->
        before (done) ->
          @user = 'mediummary'
          @password = 'testing'
          login.call @, done

        before (done) ->
          request.put
            uri: "#{serverURL}/api/#{@user}/subscription/change/medium-ec2"
          , (err, resp, body) =>
            @resp = resp
            done(err)

        it "returns a success", ->
          @resp.should.have.status 200

    context "When Recurly can't find my account", ->
      context 'PUT /api/:user/subscription/change/large-ec2', ->
        before (done) ->
          @user = 'ickletest'
          @password = 'toottoot'
          login.call @, done

        before (done) ->
          request.put
            uri: "#{serverURL}/api/#{@user}/subscription/change/large-ec2"
          , (err, resp, body) =>
            @resp = resp
            done(err)

        it "returns a failure", ->
          @resp.should.have.status 404
