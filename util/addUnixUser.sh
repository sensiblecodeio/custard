#!/bin/sh

USERNAME="$1"
UID="$2"

# Create the user
gid=$(awk -F: '/^databox:/{print $3}' /etc/group)
passwd_row="${USERNAME}:x:${UID}:${gid}::/home:/bin/bash"
shadow_row="${USERNAME}:x:15607:0:99999:7:::"
(
  flock -w 2 9 || exit 99
  { cat /shared_etc/passwd ; echo "$passwd_row" ; } > /shared_etc/passwd+
  mv /shared_etc/passwd+ /shared_etc/passwd
  { cat /shared_etc/shadow ; echo "$shadow_row" ; } > /shared_etc/shadow+
  mv /shared_etc/shadow+ /shared_etc/shadow
) 9>/shared_etc/passwd.cobalt.lock
