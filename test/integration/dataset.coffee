wd = require 'wd'
browser = wd.remote()
wd40 = require('../wd40')(browser)
should = require 'should'

url = 'http://localhost:3001' # DRY DRY DRY
login_url = "#{url}/login"

describe 'Dataset', ->
  randomname = "New favourite number is #{Math.random()}"

  before (done) ->
    wd40.init ->
      browser.get login_url, done

  before (done) ->
    wd40.fill '#username', 'ehg', ->
      wd40.fill '#password', 'testing', -> wd40.click '#login', done # This test relies on a Cheese dataset created in api.coffee!!
  context 'when I click on an Apricot dataset', ->
    before (done) ->
      browser.elementByPartialLinkText 'Apricot', (err, link) ->
        link.click done

    it 'takes me to the Apricot dataset page', (done) ->
      wd40.trueURL (err, result) ->
        result.should.match /\/dataset\/(\w+)/
        done()

    it 'shows two tools I can use on this dataset', (done) ->
      browser.elementsByCss '.dataset-views .tool', (err, tools) ->
        tools.length.should.equal 2
        done()

    it 'has not shown the input box', (done) ->
      browser.elementByCss '#subnav-path input', (err, input) ->
        browser.isVisible input, (err, visible) ->
          visible.should.be.false
          done()

    context 'when I click the title', ->
      before (done) ->
        browser.elementByCssIfExists '#subnav-path input', (err, input) =>
          @input = input
          browser.elementByCssIfExists '#subnav-path .editable', (err, a) =>
            @a = a
            wd40.click '#subnav-path .editable', done

      it 'an input box appears', (done) ->
        should.exist @input
        browser.isVisible @input, (err, visible) ->
          visible.should.be.true
          done()

      context 'when I fill in the input box and press enter', ->
        before (done) ->
          @input.clear (err) =>
            browser.type @input, randomname + '\n', ->
              done()

        before (done) ->
          browser.elementByCssIfExists '#subnav-path input', (err, input) =>
            @input = input
            browser.elementByCssIfExists '#subnav-path .editable', (err, a) =>
              @a = a
              done()

        it 'hides the input box and shows the title', (done) ->
          browser.isVisible @input, (err, inputVisible) =>
            inputVisible.should.be.false
            browser.isVisible @a, (err, aVisible) =>
              aVisible.should.be.true
              done()

        it 'has updated the title', (done) ->
          wd40.getText '#subnav-path .editable', (err, text) ->
            text.should.equal randomname
            done()

      context 'when I go back home', ->
        before (done) ->
          browser.get "#{url}/", done

        it 'should display the home page', (done) ->
          browser.url (err, url) ->
            url.should.match /\/$/
            done()

        it 'should show the new dataset new name', (done) ->
          text = wd40.getText 'body', (err, text) ->
            text.should.include randomname
            done()

        context 'when I click the "hide" button on the dataset', ->
          before (done) ->
            browser.elementByPartialLinkText randomname, (err, dataset) =>
              @dataset = dataset
              browser.moveTo @dataset, =>
                @dataset.elementByCss '.hide', (err, hide) ->
                  hide.click done

          it 'the dataset disappears from the homepage immediately', (done) ->
            # TODO: write a waitForInvisible function
            setTimeout =>
              @dataset.isVisible (err, visible) ->
                visible.should.be.false
                done()
            , 400

          context 'when I revisit the homepage', ->
            before (done) ->
              browser.refresh done

            it 'the dataset stays hidden', (done) ->
              wd40.getText 'body', (err, text) ->
                text.should.not.include randomname
                done()
