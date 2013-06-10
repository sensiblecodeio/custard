#!/bin/sh

BOX_NAME="$1"
SERVER="$2"
rsync --archive --verbose -e 'ssh -i /tmp/something' root@${SERVER}:/home/$BOX_NAME/ ${CO_STORAGE_DIR}/home/$BOX_NAME
