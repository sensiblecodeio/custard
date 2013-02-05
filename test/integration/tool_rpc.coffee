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


url = 'http://localhost:3001' # DRY DRY DRY
login_url = "#{url}/login"
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
      browser.get "#{url}/tools", ->
        browser.waitForElementByCss '.test-app.tool', 4000, ->
          browser.elementByCss '.test-app.tool', (err, link) ->
            link.click done
              
    context 'when the redirect button is pressed', ->
      before (done) ->
        browser.waitForElementByCss 'iframe', 4000, ->
          browser.frame 0, ->
            browser.waitForElementByCss '#redirect', 4000, ->
              browser.elementByCss '#redirect', (err, btn) ->
                btn.click ->
                  browser.windowHandle (err, handle) ->
                    browser.window handle, done

      it 'redirects the host to the specified URL', (done) ->
        browser.trueURL (err, url) ->
          url.should.equal url
          done()

  after (done) ->
    browser.quit ->
      done()
