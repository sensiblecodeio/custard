#!/bin/sh

export CU_DB="$(grep CU_DB /etc/init/custard.conf)"
export CU_BOX_SERVER="$(grep CU_BOX_SERVER /etc/init/custard.conf)"

cd /opt/custard
. ./activate
bin/clean_crontabs.coffee
