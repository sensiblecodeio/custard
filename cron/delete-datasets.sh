#!/bin/sh

export $(grep CU_DB /etc/init/custard.conf)
export $(grep CU_BOX_SERVER /etc/init/custard.conf)

cd /opt/custard
. ./activate
bin/clean_crontabs.coffee
