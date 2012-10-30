# scraperwiki / custard #

A platform for tools that do stuff with data.

The name's a work in progress.

AGPL Licenced.

# Stuff you need to do only once (installing)

On a mac, go to https://nodejs.org/ and install node by clicking
on the big install button.  Hopefully it will install
v0.8.something.

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
