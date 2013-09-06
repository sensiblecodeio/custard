#!/bin/bash
set -e

cd /ebs/home/$1/tool 2> /dev/null || { echo "Box $1 doesn't have a tool."; exit 1; }

if [ "$3" != "code-scraper-in-browser" ] && [ -e ../.gitconfig ] && grep -qv "Anon" ../.gitconfig; then
  echo "-----------------------------------"
  echo "Box $1 has a customised .gitconfig:"
  cat ../.gitconfig
  exit 1
fi

if git branch | grep -q -v master
then
  echo "Box $1 has a unrecognised git branch"
  exit 1
fi

count=$(git log origin/master..HEAD | wc -l)
if [ $count -ne 0 ]
then
  echo "Box $1 has a extra commits"
  exit 1
fi

IGNORE_FILES="egrep -v tool-update.log | egrep -v '^(!!|\?\?) http/' | egrep -v '\.pyc$'"

count=$(git status --porcelain --ignored | eval "$IGNORE_FILES" | wc -l)
if [ $count -ne 0 ]
then
  echo "Box $1 has extra stuff"
  git status --porcelain --ignored
  echo "##########################"
  exit 1
fi

count=$(git stash list | wc -l)
if [ $count -ne 0 ]
then
  echo "Box $1 has a stash"
  exit 1
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
  exit 1
fi

# compare .git

