# Test using Selenium WebDriver with wd bindings
# Quick instructions
# Download Selenium WebDriver
# wget http://selenium.googlecode.com/files/selenium-server-standalone-2.29.0.jar
# Download ChromeDriver
# wget http://chromedriver.googlecode.com/files/chromedriver_linux64_26.0.1383.0.zip
# (and unzip it)
# (On a Mac, or 32-bit Linux, you'll have to find and download a different binary)
# Start Selenium server
# java -jar selenium-server-standalone-2.29.0.jar -Dwebdriver.chrome.driver=<path to chromedriver>

wd = require 'wd'
should = require 'should'


BASE_URL = 'http://localhost:3001' # DRY DRY DRY
login_url = "#{BASE_URL}/login"
browser = wd.remote()

trueURL = (cb) ->
  browser.eval "window.location.href", cb

fill = (selector, text, cb) ->
  browser.waitForElementByCss selector, 4000, ->
    browser.elementByCss selector, (err, element) ->
      browser.type element, text, cb

click = (selector, cb) ->
  browser.waitForElementByCss selector, 4000, ->
    browser.elementByCss selector, (err, element) ->
      element.click cb

getText = (selector, cb) ->
  browser.waitForElementByCss selector, 4000, ->
    browser.elementByCss selector, (err, element) ->
      element.text cb

# We always switch to the first frame here!
switchToFrame = (selector, cb) ->
  browser.waitForElementByCss selector, 4000, ->
    browser.frame 0, cb

switchToTopFrame = (cb) ->
  browser.windowHandle (err, handle) ->
    browser.window handle, cb

switchToBottomFrame = (cb) ->
  switchToFrame 'iframe', ->
    switchToFrame 'iframe', cb

describe 'Tool RPC', ->
  before (done) ->
    browser.init
      browserName: process.env.BROWSER ? 'chrome'
      'chrome.switches': ['--disable-extensions']
    , (err) ->
      if err
        console.warn err
        console.warn "Is your Selenium server running? (see tool_rpc.coffee for instructions)"
      done err

  before (done) ->
    browser.get login_url, ->
      fill '#username', 'ehg', ->
        fill '#password', 'testing', ->
          click '#login', done

  context "when create a dataset with the test app", ->
    before (done) ->
      browser.get "#{BASE_URL}/tools", =>
        click '.test-app.tool', =>
          browser.waitForElementByCss 'iframe', 4000, =>
            trueURL (err, url) =>
              @toolURL = url
              done()
              
    context 'when the redirect internal button is pressed', ->
      before (done) ->
        switchToBottomFrame ->
          click '#redirectInternal', (err, btn) ->
            switchToTopFrame done

      it 'redirects the host to the specified URL', (done) ->
        trueURL (err, url) ->
          url.should.equal "#{BASE_URL}/"
          done()

    context 'when the redirect external button is pressed', ->
      before (done) ->
        browser.get @toolURL, ->
          switchToBottomFrame ->
            click '#redirectExternal', (err, btn) ->
              switchToTopFrame done

      it 'redirects the host to the specified URL', (done) ->
        trueURL (err, url) ->
          url.should.equal 'http://www.google.com/robots.txt'
          done()

    context 'when the showURL button is pressed', ->
      before (done) ->
        browser.get @toolURL, ->
          switchToBottomFrame ->
            click '#showURL', (err, btn) ->
              switchToTopFrame done

      before (done) ->
        switchToBottomFrame done

      it 'shows the scraperwiki.com URL in an element', (done) ->
        getText '#textURL', (err, text) =>
          text.should.equal @toolURL
          done()

  after (done) ->
    browser.quit ->
      done()
