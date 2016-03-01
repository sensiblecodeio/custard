# scraperwiki / custard #

A platform for tools that do stuff with data.

Together with cobalt, custard powers the [new ScraperWiki platform](https://scraperwiki.com).

AGPL Licenced (see LICENCE file).

## Initial setup (mongo, nvm)

### On Debian or Ubuntu:

    sudo apt-get install -y mongodb

You'll need a bunch of node stuff which we get using `nvm`:

    curl https://raw.github.com/creationix/nvm/master/install.sh | sh

`nvm` must be runnable, so add this line to your `.profile`:

    . ~/.nvm/nvm.sh

start a new bash terminal (in order to get `nvm` which is a shell function)

   nvm install 0.10

### On Mac OSX:

Install Node via nvm:

    curl https://raw.github.com/creationix/nvm/master/install.sh | sh
    nvm install 0.10

Install Mongo via Homebrew:

    brew install mongodb

### Then on all platforms:

Clone this repo (inside `~/sw` preferable) and from within the `custard` directory:

    mkdir mongo
    npm install pow-mongodb-fixtures -g
    mongod --dbpath=mongo # might be running already

Alongside custard, you will need to git clone swops-secret

    git clone blah blah blah

## Automatically getting the correct environment with direnv

[direnv](http://direnv.net) can be used to automatically "activate" the environment
when you enter the directory. Briefly:

    # (install go and set up your GOPATH and PATH sensibly)
    go get github.com/zimbatm/direnv
    go install github.com/zimbatm/direnv

    # append direnv setup to your bash profile
    echo 'eval "$(direnv hook $0)"' >> ${HOME}/.bashrc

    # Then cd to the custard directory and enable the .envrc with direnv:
    :~$ cd sw/custard/
    .envrc is not allowed

    :~/sw/custard$ direnv allow
    direnv: loading ~/sw/.envrc
    connect-assets not found, please run npm install
    direnv export: +NODE_PATH +PYTHONPATH +VIRTUAL_ENV ~PATH

## The first time and then every now and then (npm updates)

    # cd into the custard directory
    . activate
    npm install

## Every time you need to develop custard

If you have `foreman` installed (try `gem install foreman`)
you can go:

    foreman start

If you don't have `foreman` installed you need to do a few things
by hand:

    # Start a web server (best done in a new window)
    . activate # don't need to do this again if you've already done it in this terminal
    cake dev

The `cake dev` above starts custard the web server. It's listening on a local port (usually 3001),
so you should be able to visit `localhost:3001` in a web browser.

## Tests

We love them.

First, download Selenium Server and download and unzip Chromedriver, and put
them in your custard directory or the next level up:

- http://selenium-release.storage.googleapis.com/index.html
- http://chromedriver.storage.googleapis.com/index.html 

You need to unzip chromedriver, but not selenium.

If you're wondering about versions, right now we're having luck with:

- [Selenium Server Standalone 2.41.0](http://selenium-release.storage.googleapis.com/2.41/selenium-server-standalone-2.41.0.jar)
- [Chromedriver Mac32 2.9](http://chromedriver.storage.googleapis.com/2.9/chromedriver_mac32.zip)
- [Chromedriver Linux64 2.9](http://chromedriver.storage.googleapis.com/2.9/chromedriver_linux32.zip)

Then start the Selenium server using `cake se`:

    . activate && cake se

(this is a shortcut for running `java -jar selenium-server-standalone-2.*.0.jar -Dwebdriver.chrome.driver=chromedriver`)

To run the tests:

    . activate && cake dev       # runs a local webserver, as above
    mocha

Or one of these:

    mocha test/unit
    mocha test/integration

## Optional: running Selenium on a Windows machine

### On the Windows machine

- Make sure Java is installed
- Download the selenium-server jar file (from http://www.seleniumhq.org/download/)
- Download, unpack and add to your path the IE driver (avaiable on the same download page)
- Run Selenium Server using the command `java -jar selenium-server-standalone-2.*.0.jar`
- Run ipconfig in a cmd window to find out the IP address (e.g. 192.168.1.100)

### On your local machine

- `export SELENIUM_HOST=192.168.1.100`
- `export SELENIUM_PORT=4444`
- `export BROWSER=iexplorer`
- `export CU_TEST_SERVER=<local ip address>`
- run mocha as above and it will use the Windows machine to run the tests

## Optional: disabling startup services

You may wish to disable mongodb services from autostarting on boot when not developing custard.

(Tested on Ubuntu 12.04)

Disable mongo service:

    echo "manual" | sudo tee /etc/init/mongodb.override

Enable mongo service:

    sudo rm /etc/init/mongodb.override