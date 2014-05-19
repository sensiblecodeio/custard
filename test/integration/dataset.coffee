require './setup_teardown'
should = require 'should'
{wd40, browser, loginAndGo} = require './helper'
cleaner = require '../cleaner'

describe 'Dataset', ->
  randomname = "New favourite number is #{Math.random()}"

  before (done) ->
    # TODO(pwaller): Not sure why this is needed, but it interacts with the API
    #                tests otherwise
    cleaner.clear_and_set_fixtures done

  context 'when I click on an Apricot dataset', ->
    before (done) ->
      loginAndGo "ehg", "testing", "/datasets", done

    before (done) ->
      # wait for tiles to fade in
      wd40.elementByPartialLinkText 'Apricot', (err, link) ->
        return done(err) if err
        link.click done

    it 'takes me to the Apricot dataset page', (done) ->
      wd40.trueURL (err, result) ->
        result.should.match /\/dataset\/(\w+)/
        done()

    it 'with "Apricot" in the page title', (done) ->
      browser.title (err, title) ->
        title.should.match /Apricot/g
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

    context 'when I click the tool options icon', ->
      before (done) ->
        wd40.click '#toolbar a[href$="/settings"] .dropdown-toggle', done

      it 'there is an API endpoints link', (done) ->
        wd40.elementByCss '#tool-options-menu .api-endpoints', (err, el) ->
          done(err)

    (if process.env.SKIP_MODAL then xcontext else context) 'when I click the API endpoints link', (done) ->
      before (done) ->
        wd40.click '#tool-options-menu .api-endpoints', done

      it 'I see the box’s SQL and HTTP API endpoints', (done) ->
        wd40.elementByCss '#sql-endpoint', (err, el) ->
          el.getValue (err, val) ->
            val.should.equal 'https://localhost/3006375731/6cd21c903b864fe/sql'
            wd40.elementByCss '#http-endpoint', (err, el) ->
              el.getValue (err, val) ->
                val.should.equal 'https://localhost/3006375731/6cd21c903b864fe/http'
                done()

      after (done) ->
        wd40.click 'button[data-dismiss="modal"]', (err) ->
          wd40.waitForInvisibleByCss '.modal-backdrop', done

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

        it 'has updated the dataset title', (done) ->
          wd40.getText '#dataset-meta h3', (err, text) ->
            text.should.equal randomname
            done()

        it 'has updated the page title', (done) ->
          browser.title (err, title) ->
            title.should.match new RegExp(randomname, 'g')
            done()

      context 'when I go back home', ->
        before (done) ->
          browser.elementByCss '#logo', (err, link) ->
            link.click done

        it 'should display my home page', (done) ->
          browser.url (err, url) ->
            url.should.match /[/]datasets[/]?$/
            done()

        it 'should show the new dataset new name', (done) ->
          text = wd40.getText 'body', (err, text) ->
            text.should.include randomname
            done()

        context 'when I click the "hide" button on the dataset', ->
          before (done) ->
            # If this fails in IE try moving the mouse cursor outside of
            # the browser window while the test is running.
            # http://jimevansmusic.blogspot.co.uk/2013/01/revisiting-native-events-in-ie-driver.html
            browser.elementByPartialLinkText randomname, (err, dataset) =>
              @dataset = dataset
              browser.moveTo @dataset, =>
                @dataset.elementByCss '.hide', (err, hide) ->
                  wd40.waitForVisible hide, (err) ->
                    hide.click done

          it 'the dataset is replaced by an undo button', (done) ->
            @dataset.text (err, text) ->
              text.should.include 'Undo'
              done()

          context 'when I revisit the homepage', ->
            before (done) ->
              browser.refresh done

            it 'the dataset stays hidden', (done) ->
              wd40.getText 'body', (err, text) ->
                text.should.not.include randomname
                done()

  context "When I hide the Prune dataset", ->
    before (done) ->
      loginAndGo "ehg", "testing", "/datasets", done

    before (done) ->
      setTimeout =>
        wd40.elementByPartialLinkText 'Prune', (err, dataset) =>
          @dataset = dataset
          browser.moveTo @dataset, =>
            @dataset.elementByCss '.hide', (err, hide) ->
              wd40.waitForVisible hide, (err) ->
                hide.click done
      , 500

    it 'shows an undo button', (done) ->
      @dataset.text (err, text) ->
        text.should.include 'Undo'
        done()

    context "When I click the undo button", ->
      before (done) ->
        @dataset.elementByCss '.unhide', (err, link) ->
          link.click done

      it 'no longer shows an undo button', (done) ->
        @dataset.text (err, text) ->
          text.should.not.include 'Undo'
          done()

      it "shows the dataset title", (done) ->
        @dataset.text (err, text) ->
          text.should.include 'Prune'
          done()

  context "When I click on the Prune dataset", ->
    before (done) ->
      loginAndGo "ehg", "testing", "/datasets", ->
        setTimeout =>
          wd40.elementByPartialLinkText 'Prune', (err, dataset) =>
            dataset.click done
        , 500

    context "When I delete the dataset using the toolbar menu", ->
      before (done) ->
        wd40.click '#dataset-meta .dropdown-toggle', ->
          wd40.click '#dataset-meta .hide-dataset', done

      it "takes me back to the homepage", (done) ->
        browser.waitForElementByCss '.dataset-list', 4000, done

      it "the prune dataset is shown as deleted", (done) ->
        wd40.elementByCss '.dataset.tile', (err, tile) =>
          @dataset = tile
          @dataset.getAttribute 'class', (err, attr) ->
            attr.should.include 'deleted'
            done()

      it "there is an undo button", (done) ->
          @dataset.text (err, text) ->
            text.should.include 'Undo'
            done()

      context "When I click the undo button", ->
        before (done) ->
          @dataset.elementByCss '.unhide', (err, link) ->
            link.click done

        it 'no longer shows an undo button', (done) ->
          @dataset.text (err, text) ->
            text.should.not.include 'Undo'
            done()

        it "shows the dataset title", (done) ->
          @dataset.text (err, text) ->
            text.should.include 'Prune'
            done()

  context "When I go to a dataset that was previously deleted", ->
    before (done) ->
      loginAndGo "ehg", "testing", "/dataset/4443057115", done

    it 'shows a "dataset deleted" message', (done) ->
      wd40.getText 'body', (err, text) ->
        text.toLowerCase().should.include 'deleted'
        done()

    it 'tells me to "contact us for recovery"', (done) ->
      wd40.getText 'body', (err, text) ->
        text.toLowerCase().should.include 'contact us for recovery'
        done()

  context "When I go to a dataset URL that does not exist", ->
    before (done) ->
      loginAndGo "ehg", "testing", "/dataset/doesnotexist", done

    it 'shows a not found error', (done) ->
      wd40.getText 'body', (err, text) ->
        text.should.include 'Not found'
        done()

  context "When I go to a dataset in somebody else’s data hub, and I’m not staff", ->
    before (done) ->
      loginAndGo "test", "testing", "/dataset/1057304856", done

    it 'shows a not found error', (done) ->
      wd40.getText 'body', (err, text) ->
        text.should.include 'Not found'
        done()
