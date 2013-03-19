wd = require 'wd'
browser = wd.remote()
wd40 = require('../wd40')(browser)
should = require 'should'

url = 'http://localhost:3001' # DRY DRY DRY
login_url = "#{url}/login"

describe 'View', ->
  randomname = "Prune graph number #{Math.random()}"

  before (done) ->
    wd40.init ->
      browser.get login_url, done

  before (done) ->
    wd40.fill '#username', 'ehg', ->
      wd40.fill '#password', 'testing', -> wd40.click '#login', done

  context 'when I click on an Prune dataset', ->
    before (done) ->
      # wait for tiles to fade in
      setTimeout ->
        browser.elementByPartialLinkText 'Prune', (err, link) ->
          link.click done
      , 500

    before (done) ->
      browser.elementByPartialLinkText 'Graph of Prunes', (err, link) ->
        link.click done

    it 'takes me to the Graph of Prunes page', (done) ->
      wd40.trueURL (err, result) ->
        result.should.match /\/dataset\/(\w+)/
        done()

    it 'has not shown the input box', (done) ->
      browser.elementByCss '#editable-input', (err, input) ->
        browser.isVisible input, (err, visible) ->
          visible.should.be.false
          done()

    context 'when I click the title', ->
      before (done) ->
        browser.elementByCssIfExists '#editable-input', (err, wrapper) =>
          @wrapper = wrapper
          browser.elementByCssIfExists '#editable-input input', (err, input) =>
            @input = input
            browser.elementByCssIfExists '#subnav-path .editable', (err, a) =>
              @a = a
              wd40.click '#subnav-path .editable', done

      it 'an input box appears', (done) ->
        should.exist @input
        should.exist @wrapper
        browser.isVisible @wrapper, (err, visible) ->
          visible.should.be.true
          done()

      context 'when I fill in the input box and press enter', ->
        before (done) ->
          @input.clear (err) =>
            browser.type @input, randomname + '\n', ->
              done()

        before (done) ->
          browser.elementByCssIfExists '#editable-input', (err, wrapper) =>
            @wrapper = wrapper
            browser.elementByCssIfExists '#editable-input input', (err, input) =>
              @input = input
              browser.elementByCssIfExists '#subnav-path .editable', (err, a) =>
                @a = a
                done()

        it 'hides the input box and shows the title', (done) ->
          browser.isVisible @wrapper, (err, inputVisible) =>
            inputVisible.should.be.false
            browser.isVisible @a, (err, aVisible) =>
              aVisible.should.be.true
              done()

        it 'has updated the title', (done) ->
          wd40.getText '#subnav-path .editable', (err, text) ->
            text.should.equal randomname
            done()

      context 'when I go back to the dataset overview page', ->
        before (done) ->
          browser.elementByPartialLinkText 'Prune', (err, link) ->
            link.click done

        it 'should show the new view new name', (done) ->
          text = wd40.getText 'body', (err, text) ->
            text.should.include randomname
            done()

        xcontext 'when I click the "hide" button on the view', ->
          before (done) ->
            browser.elementByPartialLinkText randomname, (err, dataset) =>
              @dataset = dataset
              browser.moveTo @dataset, =>
                @dataset.elementByCss '.hide', (err, hide) ->
                  hide.click done

          it 'the view disappears from the dataset page immediately', (done) ->
            # TODO: write a waitForInvisible function
            setTimeout =>
              @dataset.isVisible (err, visible) ->
                visible.should.be.false
                done()
            , 400

          context 'when I revisit the dataset page', ->
            before (done) ->
              browser.refresh done

            it 'the view stays hidden', (done) ->
              wd40.getText 'body', (err, text) ->
                text.should.not.include randomname
                done()
