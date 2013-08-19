
export NODE_ENV=cron

util/listGitURLsOfDir /ebs/home | grep -v newdataset | sort -u | sudo xargs -n3 ./migrate.sh
