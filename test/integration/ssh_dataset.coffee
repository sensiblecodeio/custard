wd = require 'wd'
browser = wd.remote()
wd40 = require('../wd40')(browser)
should = require 'should'

url = 'http://localhost:3001' # DRY DRY DRY
login_url = "#{url}/login"

describe 'Dataset SSH Details', ->
  before (done) ->
    wd40.init ->
      browser.get login_url, done

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

    context 'when I click the "SSH in" menu link', ->
      before (done) ->
        wd40.click '.dataset-actions .git-ssh', done

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
          wd40.click '#add-ssh-key', done

        before (done) =>
          wd40.getText '.modal', (err, text) =>
            @modalTextContent = text.toLowerCase()
            done()

        it 'the modal window asks for my SSH key', =>
          @modalTextContent.should.include 'add your ssh key:'

        it 'the modal window gives an error', =>
          @modalTextContent.should.include 'please supply an ssh key'

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
          @modalTextContent.should.include 'ssh 3006375731@box.scraperwiki.com'

        it 'the modal includes a "copy to clipboard" button', =>
          @modalTextContent.should.include 'copy to clipboard'

        context 'when I close the modal, and reopen it', ->
          before (done) =>
            wd40.click '#done', =>
              setTimeout =>
                wd40.click '.dataset-actions .git-ssh', =>
                  wd40.getText '.modal', (err, text) =>
                    @modalTextContent = text.toLowerCase()
                    done()
              , 400

          it 'the modal window does not ask for my SSH key', =>
            @modalTextContent.should.not.include 'add your ssh key:'

          it 'the modal window tells me how to SSH in', =>
            @modalTextContent.should.include 'ssh 3006375731@box.scraperwiki.com'


  context 'when I click on the list of datasets', ->
    before (done) ->
      browser.get "#{url}/", ->
        setTimeout done, 500
    
    context 'when I click the "SSH in" menu link', ->
      before (done) ->
        browser.elementByCss '.dataset.tile .dropdown-toggle', (err, settingsLink) =>
          settingsLink.click =>
            wd40.click '.dataset.tile .git-ssh', done

      it 'a modal window appears', (done) =>
        wd40.getText '.modal', (err, text) =>
          @modalTextContent = text.toLowerCase()
          done()

      it 'the modal window does not ask for my SSH key', =>
        @modalTextContent.should.not.include 'add your ssh key:'

      it 'the modal window tells me how to SSH in', =>
        @modalTextContent.should.include 'ssh 3006375731@box.scraperwiki.com'







