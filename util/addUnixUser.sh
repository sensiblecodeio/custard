#!/bin/sh

USERNAME="$1"
UID="$2"
# TODO: exit when already exists
# Create the user
gid=$(awk -F: '/^databox:/{print $3}' /etc/group)
passwd_row="${USERNAME}:x:${UID}:${gid}::/home:/bin/bash"
shadow_row="${USERNAME}:x:15607:0:99999:7:::"
(
  flock -w 2 9 || exit 99
  { cat ${CO_STORAGE_DIR}/etc/passwd ; echo "$passwd_row" ; } > ${CO_STORAGE_DIR}/etc/passwd+
  mv ${CO_STORAGE_DIR}/etc/passwd+ ${CO_STORAGE_DIR}/etc/passwd
  { cat ${CO_STORAGE_DIR}/etc/shadow ; echo "$shadow_row" ; } > ${CO_STORAGE_DIR}/etc/shadow+
  mv ${CO_STORAGE_DIR}/etc/shadow+ ${CO_STORAGE_DIR}/etc/shadow
) 9> ${CO_STORAGE_DIR}/etc/passwd.cobalt.lock
