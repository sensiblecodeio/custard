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

We love them.

To run the tests:

    . activate && cake dev       # see above
    mocha

or one of these:

    mocha test/unit
    mocha test/integration

or even ehg's special:
    mocha test

For the integration tests, you'll need selenium running. See instructions in 
test/integration/tool_rpc.coffee


