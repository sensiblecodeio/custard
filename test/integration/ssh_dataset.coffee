should = require 'should'
{wd40, browser, base_url, login_url, home_url, prepIntegration} = require './helper'

clickSSHButton = (done) ->
  wd40.click '#toolbar a[href$="/settings"] .dropdown-toggle', (err) ->
    wd40.click '#tool-options-menu .git-ssh', done

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

    context 'when I click on the importer tool\'s SSH in button', (done) ->
      before (done) ->
        setTimeout done, 500

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

        it 'the modal title says "ssh into your Apricot tool"', =>
          @modalTextContent.should.include 'ssh into your apricot tool'

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
