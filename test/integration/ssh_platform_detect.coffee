should = require 'should'
{wd40, browser, login_url, home_url, prepIntegration} = require './helper'

clickSSHButton = (done) ->
  wd40.elementByCss '#dataset-tools-toggle', (err, link) ->
    setTimeout ->
      browser.moveTo link, (err) ->
        wd40.elementByCss '#dataset-tools a[href$="/settings"] .ssh-in', (err, sshLink) ->
          sshLink.click done
    , 1000

describe 'Platform-specific SSH instructions', ->
  prepIntegration()

  before (done) ->
    wd40.fill '#username', 'ehg', ->
      wd40.fill '#password', 'testing', -> wd40.click '#login', ->
        browser.get "#{home_url}/dataset/3006375731", done

  context 'when I use a Windows PC to view SSH instructions', ->
    before (done) ->
      browser.refresh ->
        browser.eval "window.navigator = {platform: 'Win32'}", done

    before clickSSHButton

    before (done) ->
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
        browser.eval "window.navigator = {platform: 'MacIntel'}", done

    before clickSSHButton

    before (done) ->
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
        browser.eval "window.navigator = {platform: 'Linux i686'}", done

    before clickSSHButton

    before (done) ->
      browser.waitForVisibleByCss '.modal', 4000, done

    before (done) =>
      wd40.getText '.modal', (err, text) =>
        @modalTextContent = text.toLowerCase()
        done()

    it 'the modal window tells me to use the Terminal', =>
      @modalTextContent.should.include 'terminal'

    it 'the modal window tells me to install xclip', =>
      @modalTextContent.should.include 'apt-get install xclip'

    it 'the modal window shows me the commands I should run', =>
      @modalTextContent.should.include 'xclip -sel clip < ~/.ssh/id_rsa.pub'
