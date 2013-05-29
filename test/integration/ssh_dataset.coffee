should = require 'should'
{wd40, browser, login_url, home_url, prepIntegration} = require './helper'

clickSSHButton = (done) ->
  wd40.elementByCss '#dataset-tools-toggle', (err, link) ->
    browser.moveTo link, (err) ->
      wd40.elementByCss '#dataset-tools a[href$="/settings"] .ssh-in', (err, sshLink) ->
        sshLink.click done

describe 'Dataset SSH Details', ->
  prepIntegration()

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

    # :TODO: toolbar
    xcontext 'when I click on the importer tool\'s SSH in button', (done) ->
      before clickSSHButton

      it 'a modal window appears', (done) =>
        wd40.getText '.modal', (err, text) =>
          @modalTextContent = text.toLowerCase()
          done()

      it 'the modal window asks for my SSH key', =>
        @modalTextContent.should.include 'add your ssh key:'

      it 'the modal tells me the command I should run', =>
        @modalTextContent.should.include 'ssh-keygen'

      it 'the modal includes a "copy to clipboard" button', =>
        @modalTextContent.should.include 'copy to clipboard'

      context 'when I press submit with no SSH key', ->
        before (done) ->
          setTimeout done, 100
        before (done) ->
          wd40.click '#add-ssh-key', done

        it 'the modal window asks for my SSH key', (done) ->
          wd40.waitForText 'Add your SSH key:', done

        it 'the modal window gives an error', (done) ->
          wd40.waitForText  'Please supply an SSH key', done

      context 'when I paste my private ssh key into the box and press submit', ->
        before (done) ->
          wd40.fill '#ssh-key', '''-----BEGIN RSA PRIVATE KEY-----
MII...0tXU=
-----END RSA PRIVATE KEY-----
''', ->
            wd40.click '#add-ssh-key', done

        before (done) =>
          wd40.getText '.modal', (err, text) =>
            @modalTextContent = text.toLowerCase()
            done()

        it 'the modal window asks for my SSH key', =>
          @modalTextContent.should.include 'add your ssh key:'

        it 'the modal window gives an error', =>
          @modalTextContent.should.include 'private key'

        after (done) =>
          wd40.clear '#ssh-key', done


      context 'when I paste my ssh key into the box and press submit', ->
        before (done) ->
          wd40.fill '#ssh-key', 'ssh-rsa AAAAB3Nza...ezneI9HWBOzHnh foo@bar.local', ->
            wd40.click '#add-ssh-key', done

        before (done) =>
          wd40.getText '.modal', (err, text) =>
            @modalTextContent = text.toLowerCase()
            done()

        it 'the modal title says "ssh into your Apricot dataset"', =>
          @modalTextContent.should.include 'apricot dataset'

        it 'the modal window no longer asks for my SSH key', =>
          @modalTextContent.should.not.include 'add your ssh key:'

        it 'the modal window tells me how to SSH in', =>
          @modalTextContent.should.include 'ssh 3006375731@localhost'

        it 'the modal includes a "copy to clipboard" button', =>
          @modalTextContent.should.include 'copy to clipboard'

        context 'when I close the modal, and reopen it', ->
          before (done) ->
            wd40.click '#done', ->
              setTimeout done, 400

          before clickSSHButton

          before (done) ->
            wd40.getText '.modal', (err, text) =>
              @modalTextContent = text.toLowerCase()
              done()

          it 'the modal window does not ask for my SSH key', ->
            @modalTextContent.should.not.include 'add your ssh key:'

          it 'the modal window tells me how to SSH in', ->
            @modalTextContent.should.include 'ssh 3006375731@localhost'

          it 'the modal window lets me add another SSH key', ->
            @modalTextContent.should.include 'add another ssh key'

          context 'when I click the "Add another SSH key" button', ->
            before (done) ->
              # Mysteriously, the click handler (below) doesn't
              # seems to fire reliably, unless we wait a bit.
              setTimeout done, 500

            before (done) ->
              wd40.click '#add-another-ssh-key', done

            before (done) =>
              wd40.getText '.modal', (err, text) =>
                @modalTextContent = text.toLowerCase()
                done()

            it 'the modal window asks for my SSH key', =>
              @modalTextContent.should.include 'add your ssh key:'

            it 'the modal tells me the command I should run', =>
              @modalTextContent.should.include 'ssh-keygen'


  context 'when I click on the list of datasets', ->
    before (done) ->
      browser.get "#{home_url}/", ->
        setTimeout done, 500

    context 'when I click the "SSH in" menu link', ->
      before (done) ->
        wd40.elementByPartialLinkText 'Apricot', (err, tile) ->
          tile.elementByCss '.dropdown-toggle', (err, settingsLink) ->
            settingsLink.click ->
              tile.elementByCss '.git-ssh', (err, link) ->
                link.click done

      it 'a modal window appears', (done) =>
        wd40.getText '.modal', (err, text) =>
          @modalTextContent = text.toLowerCase()
          done()

      it 'the modal window does not ask for my SSH key', =>
        @modalTextContent.should.not.include 'add your ssh key:'

      it 'the modal window tells me how to SSH in', =>
        @modalTextContent.should.include 'ssh 3006375731@localhost'
