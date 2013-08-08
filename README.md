# scraperwiki / custard #

A platform for tools that do stuff with data.

Together with cobalt, custard powers the [new ScraperWiki platform](https://scraperwiki.com).

AGPL Licenced (see LICENCE file).

## Initial setup (mongo, redis, nvm)

On Debian or Ubuntu:

    sudo apt-get install mongodb
    sudo apt-get install -y redis-server

And fix the node vesion by adding these lines to your `.profile`:

    . ~/.nvm/nvm.sh
    nvm use 0.10

On Mac OSX:

    brew install mongodb
    brew install redis

Then on all platforms:

    mkdir mongo
    npm install pow-mongodb-fixtures -g
    mongod --dbpath=mongo
    redis-server

Optionally, OSX users might want to install the mongodb and redis System Preference Panes, which make it dead easy to turn both servers on and off whenever required:

- https://github.com/remysaissy/mongodb-macosx-prefspane
- https://github.com/dquimper/Redis.prefPane

## Automatically getting the correct environment with direnv

[direnv](http://direnv.net) can be used to automatically "activate" the environment
when you enter the directory. Briefly:

    # (install go and set up your GOPATH and PATH sensibly)
    go get github.com/zimbatm/direnv
    go install github.com/zimbatm/direnv

    # append direnv setup to your bash profile
    echo 'eval "$(direnv hook $0)"' >> ${HOME}/.bashrc

## Every now and then (npm updates)

    . activate
    npm install

## Every time you need to develop custard

    # Start a web server (best done in a new window)
    . activate
    cake dev

    # If you're running tests, you'll want to
    # start a selenium server (best done in another new window)
    .activate
    cake se

## Tests

We love them. First download Selenium:

    # Linux:
    wget http://selenium.googlecode.com/files/selenium-server-standalone-2.29.0.jar
    wget http://chromedriver.googlecode.com/files/chromedriver_linux64_26.0.1383.0.zip
    unzip chromedriver

    # Mac:
    curl -O http://selenium.googlecode.com/files/selenium-server-standalone-2.29.0.jar
    curl -O https://chromedriver.googlecode.com/files/chromedriver_mac_26.0.1383.0.zip
    unzip chromedriver

Then start a Selenium server:

    . activate && cake se

(this is a shortcut for running `java -jar selenium-server-standalone-2.29.0.jar -Dwebdriver.chrome.driver=chromedriver`)

To run the tests:

    . activate && cake dev       # see above
    mocha

or one of these:

    mocha test/unit
    mocha test/integration

or even ehg's special:

    mocha test
