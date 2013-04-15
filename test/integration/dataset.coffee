should = require 'should'
{wd40, browser, login_url, home_url, prepIntegration} = require './helper'

describe 'Dataset', ->
  prepIntegration()

  randomname = "New favourite number is #{Math.random()}"

  before (done) ->
    wd40.fill '#username', 'ehg', ->
      wd40.fill '#password', 'testing', -> wd40.click '#login', done
  context 'when I click on an Apricot dataset', ->
    before (done) ->
      # wait for tiles to fade in
      setTimeout ->
        browser.elementByPartialLinkText 'Apricot', (err, link) ->
          link.click done
      , 500

    it 'takes me to the Apricot dataset page', (done) ->
      wd40.trueURL (err, result) ->
        result.should.match /\/dataset\/(\w+)/
        done()

    # Waiting for subnav change
    xit 'shows two tools I can use on this dataset', (done) ->
      browser.elementsByCss '.dataset-views .tool', (err, tools) ->
        tools.length.should.equal 2
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

      context 'when I go back home', ->
        before (done) ->
          browser.get "#{home_url}/", done

        # wait for animation :(
        before (done) ->
          setTimeout done, 500

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
