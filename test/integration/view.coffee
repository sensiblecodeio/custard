should = require 'should'
{wd40, browser, login_url, home_url, prepIntegration} = require './helper'

describe 'View', ->
  prepIntegration()

  randomname = "Prune graph number #{Math.random()}"

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

        context 'when I click the "rename" link on the view', ->
          before (done) ->
            browser.elementByPartialLinkText randomname, (err, view) =>
              @view = view
              @view.elementByCss '.dropdown-toggle', (err, settingsLink) =>
                settingsLink.click =>
                  @view.elementByCss '.rename-view', (err, renameLink) ->
                    renameLink.click done

          it "goes to the view page", (done) ->
            browser.url (err, currentUrl) =>
              currentUrl.should.match new RegExp("#{home_url}/dataset/[^/]+/view/[^/]+")
              done()

          it "has shown the rename input box", (done) ->
            browser.waitForVisibleByCss '#editable-input', 4000, done

          after (done) ->
            browser.elementByPartialLinkText 'Prune', (err, link) ->
              link.click done


        context 'when I click the "hide" link on the view', ->
          before (done) ->
            browser.elementByPartialLinkText randomname, (err, view) =>
              @view = view
              @view.elementByCss '.dropdown-toggle', (err, settingsLink) =>
                settingsLink.click =>
                  @view.elementByCss '.hide-view', (err, hideLink) ->
                    hideLink.click done

          it 'the view disappears from the dataset page immediately', (done) ->
            # TODO: write a waitForInvisible function
            setTimeout =>
              @view.isVisible (err, visible) ->
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
