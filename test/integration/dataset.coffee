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
        wd40.elementByPartialLinkText 'Apricot', (err, link) ->
          link.click done
      , 500

    it 'takes me to the Apricot dataset page', (done) ->
      wd40.trueURL (err, result) ->
        result.should.match /\/dataset\/(\w+)/
        done()

    it 'has not shown the input box', (done) ->
      wd40.elementByCss '#editable-input', (err, input) ->
        browser.isVisible input, (err, visible) ->
          visible.should.be.false
          done()

    it 'shows a toolbar including...', (done) ->
      browser.isVisible 'css selector', '#toolbar', (err, visible) =>
        visible.should.be.true
        wd40.getText '#toolbar', (err, text) =>
          @toolbarText = text.replace /\s+/g, ' '
          done()

    it '...the tool that made this dataset', ->
      @toolbarText.should.include 'Test app'

    it '...the view in a table tool', ->
      @toolbarText.should.include 'View in a table'

    it '...the spreadsheet download tool', ->
      @toolbarText.should.include 'Download as spreadsheet'

    it '...(only once)', ->
      @toolbarText.match(/Download as spreadsheet/g).length.should.equal 1

    it '...and a button to pick more tools', ->
      @toolbarText.toLowerCase().should.include 'more tools'

    context 'when I click the title', ->
      before (done) ->
        browser.elementByCssIfExists '#editable-input', (err, wrapper) =>
          @wrapper = wrapper
          browser.elementByCssIfExists '#editable-input input', (err, input) =>
            @input = input
            wd40.click '#dataset-meta .dropdown-toggle', ->
              wd40.click '#dataset-meta .rename-dataset', done

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

        it 'hides the input box and shows the new title', (done) =>
          browser.waitForVisibleByCss '#dataset-meta h3', 4000, (err) =>
            browser.isVisible 'css selector', '#editable-input', (err, inputVisible) ->
              inputVisible.should.be.false
              done()

        it 'has updated the title', (done) ->
          wd40.getText '#dataset-meta h3', (err, text) ->
            text.should.equal randomname
            done()

      context 'when I go back home', ->
        before (done) ->
          browser.elementByCss '#logo', (err, link) ->
            link.click done

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
            wd40.waitForInvisible @dataset, done

          context 'when I revisit the homepage', ->
            before (done) ->
              browser.refresh done

            it 'the dataset stays hidden', (done) ->
              wd40.getText 'body', (err, text) ->
                text.should.not.include randomname
                done()
