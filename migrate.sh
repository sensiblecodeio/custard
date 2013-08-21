#!/bin/bash

set -e

cd /ebs/home/$1/tool

mkfifo /tmp/sw-pipe
trap "wait" EXIT
trap "exec 1>&-" EXIT
trap "rm /tmp/sw-pipe" EXIT

exec 3>&1
exec 4>&2

# exec &> /tmp/sw-pipe
tee -a /tmp/migrate.log < /tmp/sw-pipe >&3 &
exec 1>/tmp/sw-pipe
exec 2>&1

if [ -e ../.gitconfig ]; then
  echo "-----------------------------------"
  echo "Box $1 has a customised .gitconfig:"
  cat ../.gitconfig
  exit
fi

if git branch | grep -q -v master
then
  echo "Box $1 has a unrecognised git branch"
  exit
fi

count=$(git log origin/master..HEAD | wc -l)
if [ $count -ne 0 ]
then
  echo "Box $1 has a extra commits"
  exit
fi

IGNORE_FILES="egrep -v tool-update.log"

count=$(git status --porcelain | eval "$IGNORE_FILES" | wc -l)
if [ $count -ne 0 ]
then
  echo "Box $1 has extra stuff"
  git status --porcelain
  echo "##########################"
  exit
fi

count=$(git stash list | wc -l)
if [ $count -ne 0 ]
then
  echo "Box $1 has a stash"
  exit
fi

IGNORE_FETCHREFS="egrep -v '^\\s+fetch = \\+refs/heads/master:refs/remotes/origin/master$' | egrep -v '^\\s+fetch = \\+refs/heads/\\*:refs/remotes/origin/\\*$' | egrep -v '^\\s+url ='"


cat .git/config | eval "$IGNORE_FETCHREFS" > /tmp/sw-git-tool
cat /tools/$3/.git/config | eval "$IGNORE_FETCHREFS" > /tmp/sw-git-tool-original

# .git/config MD5?
md5sum1="$(md5sum /tmp/sw-git-tool | awk '{print $1}')"
md5sum2="$(md5sum /tmp/sw-git-tool-original | awk '{print $1}')"
if [[ "$md5sum1" != "$md5sum2" ]]
then
  echo "------------------------------"
  echo "Box $1 has a git config change"
  echo "'$md5sum1'"
  echo "'$md5sum2'"
  diff -u /tmp/sw-git-tool-original /tmp/sw-git-tool 
  echo "------------------------------"
  exit
fi

# compare .git

