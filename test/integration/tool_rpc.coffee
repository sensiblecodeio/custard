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

# Hacky way to extend browser.
browser.trueURL = (cb) ->
  browser.eval "window.location.href", cb
  

describe 'Tool RPC', ->
  before (done) ->
    browser.init
      browserName:'chrome'
      'chrome.switches': ['--disable-extensions']
    , (err) ->
      if err
        console.warn err
        console.warn "Is your Selenium server running? (see tool_rpc.coffee for instructions)"
      done err

  before (done) ->
    browser.get login_url, ->
      browser.elementByCss '#username', (err, userField) ->
        browser.type userField, 'ehg', ->
          browser.elementByCss '#password', (err, passField) ->
            browser.type passField, 'testing', ->
              browser.elementByCss '#login', (err, loginBtn) ->
                loginBtn.click done
  

  context "when create a dataset with the test app", ->
    before (done) ->
      browser.get "#{BASE_URL}/tools", =>
        browser.waitForElementByCss '.test-app.tool', 4000, =>
          browser.elementByCss '.test-app.tool', (err, link) =>
            link.click =>
              browser.waitForElementByCss 'iframe', 4000, =>
                browser.trueURL (err, url) =>
                  @toolURL = url
                  done()
              
    context 'when the redirect button is pressed', ->
      before (done) ->
        browser.frame 0, ->
          browser.waitForElementByCss 'iframe', 4000, =>
            browser.frame 0, ->
              browser.waitForElementByCss '#redirect', 4000, ->
                browser.elementByCss '#redirect', (err, btn) ->
                  btn.click ->
                    browser.windowHandle (err, handle) ->
                      browser.window handle, done

      it 'redirects the host to the specified URL', (done) ->
        browser.trueURL (err, url) ->
          url.should.equal "#{BASE_URL}/"
          done()

    context 'when the showURL button is pressed', ->
      before (done) ->
        browser.get @toolURL, ->
          browser.waitForElementByCss 'iframe', 4004, ->
            browser.frame 0, ->
              browser.waitForElementByCss 'iframe', 4004, ->
                browser.frame 0, ->
                  browser.waitForElementByCss '#showURL', 4000, ->
                    browser.elementByCss '#showURL', (err, btn) ->
                      btn.click ->
                        browser.windowHandle (err, handle) ->
                          browser.window handle, done

      before (done) ->
        browser.waitForElementByCss 'iframe', 4000, =>
          browser.frame 0, =>
            browser.waitForElementByCss 'iframe', 4000, =>
              browser.frame 0, =>
                browser.waitForElementByCss '#textURL', 4000, =>
                  browser.elementByCss '#textURL', (err, el) =>
                    @elURL = el
                    done()


      it 'shows the scraperwiki.com URL in an element', (done) ->
        @elURL.text (err, text) =>
          text.should.equal @toolURL
          done()

  after (done) ->
    browser.quit ->
      done()
