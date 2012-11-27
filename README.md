# scraperwiki / custard #

A platform for tools that do stuff with data.

Together with cobalt, forms x.scraperwiki.com, the new ScraperWiki platform.

AGPL Licenced.

# Stuff you need to do only once (installing)

On a Mac, go to https://nodejs.org/ and install node. You'll also need to 
[download phantomjs v1.6.1](https://code.google.com/p/phantomjs/downloads/detail?name=phantomjs-1.6.1-macosx-static.zip) 
and move the executable file to `/usr/local/bin`.

On linux, install nvm.  No idea how we did that.  And phantomjs
with:

    apt-get install phantomjs

(It only installs the right version if you're using quantal
quetzal. hahaha)  Install PhantomJS 1.6.x if you can.

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


