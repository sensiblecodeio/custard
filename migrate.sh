#!/bin/bash

cd /ebs/home/$1/tool
if git remote -v | grep -v $2 > /dev/null
then
   echo "Box $1 has a unrecognised git remote" >> /tmp/migrate.log
else
   echo $1
   if git branch | grep -q -v master
   then
     echo "Box $1 has a unrecognised git branch" >> /tmp/migrate.log
     exit
   fi

   count=$(git log origin/master..HEAD | wc -l)
   if [ $count -ne 0 ]
   then
     echo "Box $1 has a extra commits" >> /tmp/migrate.log
     exit
   fi

   count=$(git status --porcelain | wc -l)
   if [ $count -ne 0 ]
   then
     echo "Box $1 has a extra stuff" >> /tmp/migrate.log
     exit
   fi

   count=$(git stash list | wc -l)
   if [ $count -ne 0 ]
   then
     echo "Box $1 has a stash" >> /tmp/migrate.log
     exit
   fi

   # .git/config MD5?
   md5sum1="$(md5sum .git/config | awk '{print $1}')"
   md5sum2="$(md5sum /tools/$3/.git/config | awk '{print $1}')"
   if [[ "$md5sum1" != "$md5sum2" ]]
   then
     echo "------------------------------"
     echo "Box $1 has a git config change"
     echo "'$md5sum1'"
     echo "'$md5sum2'"
     echo "------------------------------"
     exit
   fi

   # compare .git
fi
