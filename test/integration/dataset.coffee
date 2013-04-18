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

    it 'shows a button that shows all the tools', (done) ->
      browser.elementByPartialLinkText 'Tools', (err, link) =>
        @tools = link
        should.exist link
        done()

    it 'has not shown the input box', (done) ->
      browser.elementByCss '#editable-input', (err, input) ->
        browser.isVisible input, (err, visible) ->
          visible.should.be.false
          done()

    context 'when I click on the Tools button', (done) ->
      before (done) ->
        @tools.click =>
          wd40.getText '#dataset-tools', (err, text) =>
            @dropdownText = text
            done()

      it 'shows a dropdown menu, containing...', (done) ->
        browser.isVisible 'css selector', '#dataset-tools', (err, visible) ->
          visible.should.be.true
          done()

      it '...the tool that made this dataset', ->
        @dropdownText.should.include 'Test app'

      it '...the view in a table tool', ->
        @dropdownText.should.include 'View in a table'

      it '...the spreadsheet download tool', ->
        @dropdownText.should.include 'Download as spreadsheet'

      it '...the said spreadsheet download tool, only once', ->
        @dropdownText.match(/Download as spreadsheet/g).length.should.equal 1

      it '...the a button to pick more tools', ->
        @dropdownText.toLowerCase().should.include 'more tools'

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
          browser.elementByPartialLinkText 'data hub', (err, link) ->
            link.click done

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

  context 'when I click on a Prune dataset', ->
    before (done) ->
      # wait for tiles to fade in
      setTimeout ->
        browser.elementByPartialLinkText 'Prune', (err, link) ->
          link.click done
      , 1000

    context 'when I click on the Tools button (again)', (done) ->
      # Inexplicably we need this as well as the wait in wd40.element...
      before (done) ->
        browser.waitForElementByPartialLinkText 'Tools', 4000, done
      before (done) ->
        wd40.elementByPartialLinkText 'Tools', (err, link) =>
          @tools = link
          @tools.click =>
            wd40.getText '#dataset-tools', (err, text) =>
              @dropdownText = text
              done()

      it 'shows a dropdown menu, containing...', (done) ->
        browser.isVisible 'css selector', '#dataset-tools', (err, visible) ->
          visible.should.be.true
          done()

      it '...the tool that made this dataset', ->
        @dropdownText.should.include 'Test app'

      context 'when I go back home, and click on Prune again', ->
        before (done) ->
          browser.elementByPartialLinkText 'data hub', (err, link) ->
            link.click done

        before (done) ->
          # wait for tiles to fade in
          setTimeout ->
            browser.elementByPartialLinkText 'Prune', (err, link) ->
              link.click done
          , 500

        context 'when I click on the Tools button (again)', (done) ->
          before (done) ->
            browser.elementByPartialLinkText 'Tools', (err, link) =>
              @tools = link
              @tools.click =>
                wd40.getText '#dataset-tools', (err, text) =>
                  @dropdownText = text
                  done()

          it 'shows a dropdown menu, containing...', (done) ->
            browser.isVisible 'css selector', '#dataset-tools', (err, visible) ->
              visible.should.be.true
              done()

          it '...the tool that made this dataset', ->
            @dropdownText.should.include 'Test app'

          it '...the spreadsheet download tool', ->
            @dropdownText.should.include 'Download as spreadsheet'
