#!/bin/sh

USERNAME="$1"
UID="$2"

# Create the user
gid=$(awk -F: '/^databox:/{print $3}' /etc/group)
passwd_row="${USERNAME}:x:${UID}:${gid}::/home:/bin/bash"
shadow_row="${USERNAME}:x:15607:0:99999:7:::"
(
  flock -w 2 9 || exit 99
  { cat /etc/passwd ; echo "$passwd_row" ; } > /etc/passwd+
  mv /etc/passwd+ /etc/passwd
  { cat /etc/shadow ; echo "$shadow_row" ; } > /etc/shadow+
  mv /etc/shadow+ /etc/shadow
) 9>/etc/passwd.cobalt.lock
