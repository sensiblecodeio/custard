set -e 

export NODE_ENV=cron

tee /tmp/migrate.log < /dev/null

mkfifo /tmp/sw-pipe
trap "wait" EXIT
trap "exec 1>&-" EXIT
trap "rm /tmp/sw-pipe" EXIT

exec 3>&1
exec 4>&2

tee -a /tmp/migrate.log < /tmp/sw-pipe >&3 &
exec 1>/tmp/sw-pipe
exec 2>&1

util/listGitURLsOfDir /ebs/home | grep -v newdataset | sort -u |
  while read -r BOX GIT_URL TOOLNAME
  do
    if ./should-migrate.sh $BOX $GIT_URL $TOOLNAME &>> /tmp/migrate.log
    then
      echo ---- Migrating box $BOX -- $TOOLNAME
    else
      echo ---- Skipping box $BOX -- $TOOLNAME
    fi
  done
