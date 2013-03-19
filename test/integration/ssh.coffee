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

      it 'an modal window appears', (done) =>
        wd40.getText '#modal', (err, text) =>
          @modalTextContent = text.toLowerCase()
          done()
        
      it 'the modal window asks for my SSH key', =>
        @modalTextContent.should.include 'add your ssh key:'
        
      it 'the modal tells me the command I should run', =>
        @modalTextContent.should.include 'ssh-keygen'

      context 'when I paste my ssh key into the box and press submit', ->
        before (done) ->
          wd40.fill '#ssh-key', 'ssh-rsa AAAAB3Nza...ezneI9HWBOzHnh foo@bar.local', ->
            wd40.click '#add-ssh-key', done

        it 'the modal window no longer asks for my SSH key', (done) ->
          wd40.getText '#modal', (err, text) ->
            text.toLowerCase().should.not.include 'add your ssh key:'
            done()
