wd = require 'wd'
browser = wd.remote()
wd40 = require('../wd40')(browser)
should = require 'should'

url = 'http://localhost:3001' # DRY DRY DRY
login_url = "#{url}/login"

describe 'Platform-specific SSH instructions', ->
  before (done) ->
    wd40.init ->
      browser.get login_url, done

  before (done) ->
    wd40.fill '#username', 'ehg', ->
      wd40.fill '#password', 'testing', -> wd40.click '#login', ->
        browser.get "#{url}/dataset/3006375731", done
      
  context 'when I use a Windows PC to view SSH instructions', ->
    before (done) ->
      browser.refresh ->
        browser.eval "window.navigator = {platform: 'Win32'}", ->
          wd40.click '.dataset-actions .git-ssh', ->
            browser.waitForVisibleByCss '.modal', 4000, done
    
    before (done) =>
        wd40.getText '.modal', (err, text) =>
          @modalTextContent = text.toLowerCase()
          done()

    it 'the modal window tells me to use Git Bash', =>
      @modalTextContent.should.include 'git bash'

    it 'the modal window shows me the Windows commands I should run', =>
      @modalTextContent.should.include 'clip < ~/.ssh/id_rsa.pub'

  context 'when I use a Mac to view SSH instructions', ->
    before (done) ->
      browser.refresh ->
        browser.eval "window.navigator = {platform: 'MacIntel'}", ->
          wd40.click '.dataset-actions .git-ssh', ->
            browser.waitForVisibleByCss '.modal', 4000, done

    before (done) =>
        wd40.getText '.modal', (err, text) =>
          @modalTextContent = text.toLowerCase()
          done()

    it 'the modal window tells me to use the Terminal', =>
      @modalTextContent.should.include 'terminal'

    it 'the modal window shows me the Mac commands I should run', =>
      @modalTextContent.should.include 'pbcopy < ~/.ssh/id_rsa.pub'

  context 'when I use a Linux computer to view SSH instructions', ->
    before (done) ->
      browser.refresh ->
        browser.eval "window.navigator = {platform: 'MacIntel'}", ->
          wd40.click '.dataset-actions .git-ssh', ->
            browser.waitForVisibleByCss '.modal', 4000, done

    before (done) =>
        wd40.getText '.modal', (err, text) =>
          @modalTextContent = text.toLowerCase()
          done()

    it 'the modal window tells me to use the Terminal', =>
      @modalTextContent.should.include 'terminal'

    it 'the modal window tells me to install xclip', =>
      @modalTextContent.should.include 'apt-get install xclip'

    it 'the modal window shows me the Mac commands I should run', =>
      @modalTextContent.should.include 'xclip -sel clip < ~/.ssh/id_rsa.pub'
