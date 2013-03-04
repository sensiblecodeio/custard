# scraperwiki / custard #

A platform for tools that do stuff with data.

Together with cobalt, forms x.scraperwiki.com, the new ScraperWiki platform.

AGPL Licenced (see LICENCE file).

# Stuff you need to do only once (installing)

## Install zombie

The tests require a specially patched version of zombie:

    cd ~/sw     # switch to directory containing all our repos.
    git clone git@github.com:scraperwiki/zombie.git
    cd zombie
    npm link
    cd ../custard
    npm link zombie     # Makes custard use our local copy of zombie

## Install mongodb

On Debian or Ubuntu:

    sudo apt-get mongodb

On Mac OSX:

    brew install mongodb

Then on all platforms:

    mkdir mongo
    npm install pow-mongodb-fixtures -g
    mongod --dbpath=mongo

# Every time you need to develop custard:

    . activate
    . ~/.nvm/nvm.sh # Only on linux, and could be in your .profile.
    nvm use 0.8 # Only if you're using nvm.
    npm install # Only needed if package.json changes.

    # This will start a development web server.  Best
    # done in a separate window.
    cake dev

    # You'll also need swops-secret and you'll need to git pull it
    # every now and then.

    # Some of the tests may need to start a selenium server.

# Tests

We love them. First download Selenium:

    wget http://selenium.googlecode.com/files/selenium-server-standalone-2.29.0.jar
    (linux) wget http://chromedriver.googlecode.com/files/chromedriver_linux64_26.0.1383.0.zip
    (mac) wget https://chromedriver.googlecode.com/files/chromedriver_mac_26.0.1383.0.zip
    unzip chromedriver

Then start a Selenium server:

    java -jar selenium-server-standalone-2.29.0.jar -Dwebdriver.chrome.driver=chromedriver

To run the tests:

    . activate && cake dev       # see above
    mocha

or one of these:

    mocha test/unit
    mocha test/integration

or even ehg's special:
    mocha test


