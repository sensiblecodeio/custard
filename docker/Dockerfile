FROM scraperwiki/base:precise

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install -y mongodb
RUN apt-get install -y python-software-properties

RUN apt-add-repository -y ppa:chris-lea/node.js
RUN apt-get update
RUN apt-get install -y nodejs
RUN apt-get install -y netcat lsof

RUN mkdir /opt/custard