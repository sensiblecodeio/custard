# scraperwiki / custard #

A platform for tools that do stuff with data.

Together with cobalt, forms x.scraperwiki.com, the new ScraperWiki platform.

AGPL Licenced (see LICENCE file).

# Stuff you need to do only once (installing)

## Install mongodb

On Debian or Ubuntu:

    sudo apt-get install mongodb

On Mac OSX:

    brew install mongodb

Then on all platforms:

    mkdir mongo
    npm install pow-mongodb-fixtures -g
    mongod --dbpath=mongo

# Every time you need to develop custard:

    . activate
    . ~/.nvm/nvm.sh # Only on linux, and could be in your .profile.
    nvm use 0.10 # Only if you're using nvm.
    npm install # Only needed if package.json changes.

    # This will start a development web server.  Best
    # done in a separate window.
    cake dev

    # You'll also need swops-secret and you'll need to git pull it
    # every now and then.

    # Some of the tests may need to start a selenium server
    (```cake se```).

# Tests

We love them. First download Selenium:

    wget http://selenium.googlecode.com/files/selenium-server-standalone-2.29.0.jar
    (linux) wget http://chromedriver.googlecode.com/files/chromedriver_linux64_26.0.1383.0.zip
    (mac) wget https://chromedriver.googlecode.com/files/chromedriver_mac_26.0.1383.0.zip
    unzip chromedriver

Then start a Selenium server:

    . activate && cake se

(this is a shortcut for running ```java -jar selenium-server-standalone-2.29.0.jar -Dwebdriver.chrome.driver=chromedriver```)

To run the tests:

    . activate && cake dev       # see above
    mocha

or one of these:

    mocha test/unit
    mocha test/integration

or even ehg's special:
    mocha test
