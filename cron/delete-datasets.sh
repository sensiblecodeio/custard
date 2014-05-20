#!/bin/bash

export $(grep CU_DB /etc/init/custard.conf)
export $(grep CU_BOX_SERVER /etc/init/custard.conf)

source /etc/custard/production-activate
/opt/custard/bin/clean_crontabs.coffee
