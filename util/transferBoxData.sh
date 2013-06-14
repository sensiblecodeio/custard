#!/bin/sh

BOX_NAME="$1"
SERVER="$2"
case $SERVER in
  (*ec2*)
    rsync --archive --verbose -e 'ssh' --rsync-path 'sudo rsync' ubuntu@${SERVER}:/home/$BOX_NAME/ ${CO_STORAGE_DIR}/home/$BOX_NAME
    ;;
  (*)
    rsync --archive --verbose -e 'ssh -oIdentitiesOnly=yes -i /tmp/something' root@${SERVER}:/home/$BOX_NAME/ ${CO_STORAGE_DIR}/home/$BOX_NAME
    ;;
esac
