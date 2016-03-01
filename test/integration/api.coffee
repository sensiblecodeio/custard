require './setup_teardown'
net = require 'net'
helper = require './helper'

_ = require 'underscore'
request = require 'request'
should = require 'should'
async = require 'async'

# Timeout period in milliseconds for duplicate request
# debouncing. (see underscore debounce and test that uses these)
DEBOUNCE_PERIOD = 1000
EPSILON = 100

login = (done) ->
  @loginURL = "#{helper.base_url}/login"
  request.get
    uri: "#{helper.base_url}/logout"
    followRedirect: false
  , (err) =>
    if err
      return done err
    request.get @loginURL, (err) =>
      if err
        return done err
      request.post
        uri: @loginURL
        form:
          username: @user
          password: @password
      , (err, res) =>
        @loginResponse = res
        done(err)

parseJSON = (string) ->
  object = undefined
  try
    object = JSON.parse string
  catch error
    throw new Error "Invalid JSON: #{string}"
  return object

describe 'API', ->
  before ->
    @toolName = "int-test-#{String(Math.random()*Math.pow(2,32))[0..6]}"

  before (done) ->
    request.get
      uri: "#{helper.base_url}/api/"
    , (err, res, body) =>
      @response = res
      @err = err
      done()

  before (done) ->
    # If this fails the server isn't running and you should run "cake dev".
    @err?.should.equal null
    @response.statusCode.should.equal 200
    done()

  context "When I'm not logged in", ->

    describe 'I can sign up', ->
      context 'POST /api/<username>', ->
        before (done) ->
          request.post
            uri: "#{helper.base_url}/api/user/"
            form:
              shortName: 'tabbytest'
              displayName: 'Tabatha Testerson'
              email: 'tabby@example.org'
              inviteCode: process.env.CU_INVITE_CODE
              acceptedTerms: 1
          , (err, res, body) =>
            @body = parseJSON body
            done()

        it 'returns a JSON string containing the new user\'s details', ->
          @body.should.not.have.property 'error'
          @body.should.include
            shortName: 'tabbytest'
            displayName: 'Tabatha Testerson'

    describe 'I can request a password reset email', ->
      context 'POST /api/user/reset-password/', ->
        before (done) ->
          request.post
            uri: "#{helper.base_url}/api/user/reset-password"
            form:
              query: 'ickletest'
          , (err, res, body) =>
            @response = res
            console.log "reset-password", body
            @body = parseJSON body
            done()

        it 'returns a HTTP 200 status', ->
          @response.statusCode.should.equal 200

        it 'returns a JSON string with a success message', ->
          @body.should.not.have.property 'error'
          @body.should.have.property 'success'
          @body.success.should.equal 'A password reset link has been emailed to ickletest'

    describe 'I can’t request a password reset email for a user that doesn’t exist', ->
      context 'POST /api/user/set-password/', ->
        before (done) ->
          request.post
            uri: "#{helper.base_url}/api/user/reset-password"
            form:
              query: 'i-do-not-exist'
          , (err, res, body) =>
            @response = res
            @body = parseJSON body
            done()

        it 'returns a HTTP 404 status', ->
          @response.statusCode.should.equal 404

        it 'returns a JSON string with an error message', ->
          @body.should.not.have.property 'success'
          @body.should.have.property 'error'
          @body.error.should.equal 'That username could not be found'

    describe 'I get a sensible error message when a user doesn’t have a password token', ->
      context 'POST /api/user/set-password/', ->
        before (done) ->
          request.post
            uri: "#{helper.base_url}/api/user/reset-password"
            form:
              query: 'ehg'
          , (err, res, body) =>
            @response = res
            @body = parseJSON body
            done()

        it 'returns a HTTP 500 status', ->
          @response.statusCode.should.equal 500

        it 'returns a JSON string with an error message', ->
          @body.should.not.have.property 'success'
          @body.should.have.property 'error'
          @body.error.should.equal 'Something went wrong: token not found'


  context "When I have set my password", ->
    before (done) ->
      @token = '339231725782156'
      @user = 'ickletest'
      @password = 'toottoot'
      @fullName = 'Mr Ickle Test'

      # Set password & login
      request.post
        uri: "#{helper.base_url}/api/token/#{@token}"
        form:
          password: @password
      , done

    describe 'Tools', ->

      context 'GET /api/tools', ->
        before (done) ->
          request.get "#{helper.base_url}/api/tools", (err, res) =>
            @body = res.body
            @tools = parseJSON @body
            done()

        it 'returns a list of tools', ->
          @tools.length.should.be.above 0

        # TODO(drj): If tools are hanging around, we should make sure that the
        # behaviour of private tools is correct.
        xit "includes my private tool", ->
          should.exist(_.find @tools, (x) => x.name == "#{@toolName}-private")

        it "includes public tools", ->
          should.exist(_.find @tools, (x) => x.name == "test-app")

        it 'returns the right fields', ->
          should.exist @tools[0].name
          should.exist @tools[0].gitUrl
          should.exist @tools[0].type

    describe 'Datasets', ->

      context 'when I try to create a dataset with bad parameters', ->
        context 'no tool specified', ->
          before (done) ->
            request.post
              uri: "#{helper.base_url}/api/#{@user}/datasets"
              form:
                # no tool
                displayName: 'Broken'
            , (err, res, body) =>
              @response = res
              done()

          it 'does not create a new dataset', ->
            @response.statusCode.should.equal 500


      context 'when I create a dataset', ->

        createDatasets = (number, opts, callback) ->
          functionArr = []
          callback = opts unless arguments[2]?
          for i in [1..number]
            functionArr.push (cb) =>
              random = String(Math.random()*Math.pow(2,32))[0..4]
              request.post
                uri: "#{helper.base_url}/api/#{opts.user or 'ickletest'}/datasets"
                form:
                  displayName: opts.displayName or "Dataset #{random}"
                  tool: opts.tool or 'test-app'
              , cb

          async.series functionArr, (err, res) ->
            if err
              callback err, res
            if res.length is 1
              callback err, res[0][0], res[0][1]
            else
              callback err, res

        before (done) ->
          createDatasets 1,
            displayName: 'Biscuit'
            tool: 'test-app'
            user: @user
          , (err, res, body) =>
            @response = res
            @dataset = parseJSON res.body
            done()

        context 'POST /api/:user/datasets', ->
          it 'creates a new dataset', ->
            @response.statusCode.should.equal 200

          it 'returns the newly created dataset', ->
            should.exist @dataset.box
            @dataset.displayName.should.equal 'Biscuit'

          it 'has an associated boxServer...', ->
            should.exist @dataset.boxServer

        context 'GET /api/:user/datasets/:id', ->
          it 'returns a single dataset', (done)  ->
            request.get "#{helper.base_url}/api/#{@user}/datasets/#{@dataset.box}", (err, res) ->
              newDataset = parseJSON res.body
              should.exist newDataset.box
              done()

          it 'dataset has a created date', (done)  ->
            request.get "#{helper.base_url}/api/#{@user}/datasets/#{@dataset.box}", (err, res) ->
              newDataset = parseJSON res.body
              Date.parse(newDataset.createdDate).should.be.above(0)
              done()

          it 'dataset has a creator short name', (done)  ->
            request.get "#{helper.base_url}/api/#{@user}/datasets/#{@dataset.box}", (err, res) ->
              newDataset = parseJSON res.body
              'ickletest'.should.equal newDataset.creatorShortName
              done()

          it 'dataset has a creator display name', (done)  ->
            request.get "#{helper.base_url}/api/#{@user}/datasets/#{@dataset.box}", (err, res) ->
              newDataset = parseJSON res.body
              'Ickle Test'.should.equal newDataset.creatorDisplayName
              done()

          it "404 errors if the dataset doesn't exist", (done) ->
            request.get "#{helper.base_url}/api/#{@user}/datasets/NOTEXIST", (err, res) ->
              res.statusCode.should.equal 404
              done()

          it "403 errors if the user doesn't exist", (done) ->
            request.get "#{helper.base_url}/api/MRINVISIBLE/datasets/#{@dataset.box}", (err, res) ->
              res.statusCode.should.equal 403
              done()

          context 'I create some more', ->
            before (done) ->
              createDatasets 2, ->
                done()

            it "doesn't let me create the 4th one", (done) ->
              createDatasets 1, (err, res, body) ->
                res.statusCode.should.equal 402
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
               @response.statusCode.should.equal 402

        describe 'Views', ->
          context 'when I create a view on a dataset', ->
            before (done) ->
              request.post
                uri: "#{helper.base_url}/api/#{@user}/datasets/#{@dataset.box}/views"
                form:
                  name: 'carrottop'
                  displayName: 'Carrot Top'
                  tool: 'test-plugin'
              , (err, res, body) =>
                @response = res
                @view = null
                if res
                  @view = parseJSON res.body
                done()

            context 'POST /api/:user/datasets/<dataset>/views', ->
              it 'creates a new dataset', ->
                @response.statusCode.should.equal 200

              it 'returns the newly created view', ->
                should.exist @view.box
                @view.displayName.should.equal 'Carrot Top'

              it 'has an associated boxServer...', ->
                should.exist @view.boxServer

          context 'when I attempt to create a view on a bogus dataset', ->
            context 'POST /api/:user/datasets/bogus/views', ->
              it 'returns 404', (done) ->
                request.post
                  uri: "#{helper.base_url}/api/#{@user}/datasets/bogus/views"
                  form:
                    name: 'carrottop'
                    displayName: 'Carrot Top'
                    tool: 'test-plugin'
                , (err, res, body) =>
                  @response = res
                  should.exist @response
                  @response.statusCode.should.equal 404
                  done()


        context 'PUT /api/:user/datasets/:id', ->
          it 'changes the display name of a single dataset', (done) ->
            request.put
              uri: "#{helper.base_url}/api/#{@user}/datasets/#{@dataset.box}"
              form:
                displayName: 'Cheese'
            , (err, res) =>
              res.statusCode.should.equal 200
              request.get "#{helper.base_url}/api/#{@user}/datasets/#{@dataset.box}", (err, res) =>
                @dataset = parseJSON res.body
                'Cheese'.should.equal @dataset.displayName
                done(err)

          it 'changes the owner of a single dataset', (done) ->
            @newowner = 'ehg'
            request.put
              uri: "#{helper.base_url}/api/#{@user}/datasets/#{@dataset.box}"
              form:
                user: @newowner
            , (err, res) =>
              res.statusCode.should.equal 200
              done(err)

          it "that dataset doesn't appear in my list of datasets any more", (done) ->
            request.get "#{helper.base_url}/api/#{@user}/datasets", (err, res) =>
              res.body.should.not.include "#{@dataset.box}"
              done()

          it "404 errors if the dataset doesn't exist", (done) ->
            request.put "#{helper.base_url}/api/#{@user}/datasets/NOTEXIST", (err, res) ->
              res.statusCode.should.equal 404
              done()

      context 'GET: /api/:user/datasets', ->
        it 'returns a list of datasets', (done) ->
          request.get "#{helper.base_url}/api/#{@user}/datasets", (err, res) ->
            datasets = parseJSON res.body
            datasets.length.should.be.above 0
            done err

      context '/api/:user/sshkeys', ->
        it 'POST: returns ok', (done) ->
          request.post
            uri: "#{helper.base_url}/api/#{@user}/sshkeys"
            form:
              key: '  ssh-rsa AAAAB3NzaC1yc2EAAAAD...mRRu21YYMK7GSE7gZTtbI65WJfreqUY472s8HVIX foo@bar.local\n\n'
          , (err, res) ->
            res.body.should.include 'ok'
            done err

        it 'GET: returns the key with whitespace trim', (done) ->
          request.get
            uri: "#{helper.base_url}/api/#{@user}/sshkeys"
          , (err, res) ->
            keys = parseJSON res.body
            keys.should.include 'ssh-rsa AAAAB3NzaC1yc2EAAAAD...mRRu21YYMK7GSE7gZTtbI65WJfreqUY472s8HVIX foo@bar.local'
            done err

      context 'PUT: /api/user', ->
        it 'lets me accept the terms and conditions', (done) ->
          request.put
            uri: "#{helper.base_url}/api/user"
            form:
              acceptedTerms: 7
          , (err, res, body) =>
            res.statusCode.should.equal 200
            obj = parseJSON body
            obj.acceptedTerms.should.equal 7
            done err

        it 'does not let me change my user name', (done) ->
          request.put
            uri: "#{helper.base_url}/api/user"
            form:
              shortName: 'zebadee'
          , (err, res) =>
            obj = parseJSON res.body
            obj.shortName.should.not.equal 'zebadee'
            done err

        it 'does let me change my canBeReally field', (done) ->
          request.put
            uri: "#{helper.base_url}/api/user"
            form:
              canBeReally: ["test", "teststaff"]
            , (err, res) ->
              res.statusCode.should.equal 200
              obj = parseJSON res.body
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

        doRequest = (_, cb) ->
          request.post
            uri: "#{helper.base_url}/api/status"
            form:
              type: "ok"
              message: "just testing"
          , (err, res, body) ->
            # This relies on the fact that there is a box with
            # the same name as your userid. Add one to
            # fixtures.js if there isn't one already.
            res.statusCode.should.equal 200
            obj = parseJSON body
            cb err

    describe 'Billing', ->
      context 'GET /api/:user/subscription/medium/sign', ->
        before (done) ->
          request.get
            uri: "#{helper.base_url}/api/#{@user}/subscription/medium/sign"
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
            uri: "#{helper.base_url}/api/#{@user}/subscription/verify"
            form:
              recurly_token: '34324sdfsdf'
          , (err, res, body) =>
            @res = res
            done err

        it 'returns a 404 (the token is unknown)', ->
          @res.statusCode.should.equal 404

  describe 'Switching', ->
    context 'GET /switch/ickletest', ->
      context "When ickletest has approved", ->
        before (done) ->
          # logout
          request.get "#{helper.base_url}/logout", done
        before (done) ->
          @loginURL = "#{helper.base_url}/login"
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
            uri: "#{helper.base_url}/switch/ickletest"
            followRedirect: false
          , (err, res) ->
            res.statusCode.should.equal 302
            done()

    context 'GET /api/user', ->
      before (done) ->
        request.get "#{helper.base_url}/api/user", (err, res, body) =>
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
        request.get "#{helper.base_url}/api/testersonltd/datasets", (err, res) ->
          res.statusCode.should.equal 200
          done err

    context "When we login as ehg", ->
      before (done) ->
        @user = "ehg"
        @password = "testing"
        login.call @, done

      it "doesn't force me into a different context", (done) ->
        request.get "#{helper.base_url}/api/ehg/datasets", (err, res) ->
          res.statusCode.should.equal 200
          done err

  describe 'Logging in as a different user', ->
    context "When I'm a staff member", ->
      before (done) ->
        @user = 'teststaff'
        @password = process.env.CU_TEST_STAFF_PASSWORD
        login.call @, done

      before (done) ->
        request.get "#{helper.base_url}/api/tools", (err, res) =>
          @body = res.body
          @tools = parseJSON @body
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
          uri: "#{helper.base_url}/api/user"
          form:
            shortName: @newUser
            email: 'random@example.org'
            displayName: 'Ran Dom Test'
        , (err, resp, body) =>
          obj = parseJSON body
          @token = obj.token
          resp.statusCode.should.equal 201
          done(err)

      it '... and I can set the password', (done) ->
        request.post
          uri: "#{helper.base_url}/api/token/#{@token}"
          form:
            password: @newPassword
        , (err, resp, body) ->
          resp.statusCode.should.equal 200
          done(err)

  describe "Private tools", ->
    before (done) ->
      @user = 'teststaff'
      @password = process.env.CU_TEST_STAFF_PASSWORD
      login.call @, done

    context 'When I add allowedUsers', ->
      before (done) ->
        request.post
          uri: "#{helper.base_url}/api/tools"
          form:
            name: "shared-private"
            type: 'view'
            gitUrl: 'git://github.com/scraperwiki/test-plugin-tool.git'
            public: false
            allowedUsers: ['test', 'ickletest']
        , (err, res, body) =>
          @response = res
          @tool = parseJSON res.body
          done()

      it 'is shared with some users', ->
        @tool.allowedUsers.should.eql ['test', 'ickletest']

    context 'When I add allowedPlans', ->
      before (done) ->
        request.post
          uri: "#{helper.base_url}/api/tools"
          form:
            name: "shared-less-private"
            type: 'view'
            gitUrl: 'git://github.com/scraperwiki/test-plugin-tool.git'
            public: false
            allowedPlans: ['free']
        , (err, res, body) =>
          @response = res
          @tool = parseJSON res.body
          done()

      it 'is shared with users on some plans', ->
        @tool.allowedPlans.should.eql ['free']

    context 'When I log in as test', ->
      before (done) ->
       @user = "test"
       @password = "testing"
       login.call @, done

      before (done) ->
        @toolsURL = "#{helper.base_url}/api/tools"
        request.get
          uri: @toolsURL,
        , (err, res, body) =>
          @tools = parseJSON body
          done()

      it "includes the private tool we shared with test and ickletest", ->
        should.exist(_.find @tools, (x) => x.name == "shared-private")

    context 'When I log in as test (a free user)', ->
      before (done) ->
       @user = "test"
       @password = "testing"
       login.call @, done

      before (done) ->
        @toolsURL = "#{helper.base_url}/api/tools"
        request.get
          uri: @toolsURL,
        , (err, res, body) =>
          @tools = parseJSON body
          done()

      it "includes the tool we shared with all free users", ->
        should.exist(_.find @tools, (x) => x.name == "shared-less-private")

    context 'When I log in as ehg (a grandfather user)', ->
      before (done) ->
       @user = "ehg"
       @password = "testing"
       login.call @, done

      before (done) ->
        @toolsURL = "#{helper.base_url}/api/tools"
        request.get
          uri: @toolsURL,
        , (err, res, body) =>
          @tools = parseJSON body
          done()

      it "does not include the tool we shared with free users", ->
        should.not.exist(_.find @tools, (x) => x.name == "shared-less-private")

      it "does not include the private tool we shared with test and ickletest", ->
        should.not.exist(_.find @tools, (x) => x.name == "shared-private")

  describe 'Editing my Recurly billing details', ->
    context 'GET /api/mediummary/subscription/billing', ->
      before (done) ->
       @user = 'mediummary'
       @password = 'testing'
       login.call @, done

      it "redirects to a Recurly hosted admin page", (done) ->
        request.get
          uri: "#{helper.base_url}/api/mediummary/subscription/billing",
          followRedirect: false
        , (err, res, body) ->
          should.not.exist err
          res.statusCode.should.equal 302
          res.headers.location.should.match new RegExp("^https://[^.]+[.]recurly[.]com/account/[a-z0-9]+$")
          done()

    context 'GET /api/test/subscription/billing', ->
      before (done) ->
       @user = 'test'
       @password = 'testing'
       login.call @, done

      it "returns an error because ‘test’ has no Recurly account", (done) ->
        request.get
          uri: "#{helper.base_url}/api/test/subscription/billing",
          followRedirect: false
        , (err, res, body) ->
          should.not.exist err
          res.statusCode.should.equal 404
          bodyObj = JSON.parse body
          should.exist bodyObj.error
          bodyObj.error.should.match /You have no Recurly account/
          done()

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
            uri: "#{helper.base_url}/api/#{@user}/subscription/change/large-ec2"
          , (err, resp, body) =>
            @resp = resp
            done(err)

        it "returns a success", ->
          @resp.statusCode.should.equal 200

    context "When I'm downgrading from large to medium", ->
      context 'PUT /api/:user/subscription/change/medium-ec2', ->
        before (done) ->
          @user = 'mediummary'
          @password = 'testing'
          login.call @, done

        before (done) ->
          request.put
            uri: "#{helper.base_url}/api/#{@user}/subscription/change/medium-ec2"
          , (err, resp, body) =>
            @resp = resp
            done(err)

        it "returns a success", ->
          @resp.statusCode.should.equal 200

    context "When Recurly can't find my account", ->
      context 'PUT /api/:user/subscription/change/large-ec2', ->
        before (done) ->
          @user = 'ickletest'
          @password = 'toottoot'
          login.call @, done

        before (done) ->
          request.put
            uri: "#{helper.base_url}/api/#{@user}/subscription/change/large-ec2"
          , (err, resp, body) =>
            @resp = resp
            done(err)

        it "returns a failure", ->
          @resp.statusCode.should.equal 404
