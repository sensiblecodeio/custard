require './setup_teardown'
should = require 'should'
{wd40, browser, loginAndGo} = require './helper'
cleaner = require '../cleaner'

clickSSHButton = (done) ->
  wd40.click '#toolbar a[href$="/settings"] .dropdown-toggle', (err) ->
    wd40.click '#tool-options-menu .git-ssh', done


# TODO(pwaller): Conditionally disable modal depending on whether we're in
# an environment that supports it.
(if process.env.SKIP_MODAL then xdescribe else describe) 'Platform-specific SSH instructions', ->

  before (done) ->
    # Needed so that SSH keys are deleted
    cleaner.clear_and_set_fixtures done

  before (done) ->
    loginAndGo "ehg", "testing", "/dataset/3006375731", done

  context 'when I use a Windows PC to view SSH instructions', ->
    before (done) ->
      setTimeout done, 500

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
      setTimeout done, 500

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
      setTimeout done, 500

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

