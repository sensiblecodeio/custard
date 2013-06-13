#!/bin/sh

BOX_NAME="$1"
SERVER="$2"
case $SERVER in
  (*ec2*)
    echo "I'm sorry Dave, I don't know how to migrate from an ec2 server..."
    rsync --archive --verbose -e 'ssh' --rsync-path 'sudo rsync' root@${SERVER}:/home/$BOX_NAME/ ${CO_STORAGE_DIR}/home/$BOX_NAME
    ;;
  (*)
    rsync --archive --verbose -e 'ssh -i /tmp/something' root@${SERVER}:/home/$BOX_NAME/ ${CO_STORAGE_DIR}/home/$BOX_NAME
    ;;
esac
