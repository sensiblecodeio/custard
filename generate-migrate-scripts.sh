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

MIGRATE_FILE="${PWD}/migrate-$(hostname).sh"

cat <<EOF > $MIGRATE_FILE
UNMIGRATE_FILE="${PWD}/unmigrate-$(hostname).sh"
: > \$UNMIGRATE_FILE
EOF
#echo "ffaalqy -- spreadsheet-download " |
util/listGitURLsOfDir /ebs/home | 
egrep -v 'new(view|dataset)$' | sort -u |
  while read -r BOX GIT_URL TOOLNAME
  do
    if ./should-migrate.sh $BOX $GIT_URL $TOOLNAME &>> /tmp/migrate.log
    then
      echo ---- Migrating box $BOX -- $TOOLNAME
      #   
      (
      cd "/ebs/home/$BOX/tool" 
      MHF="$(git status --porcelain --ignored http | egrep '^(!!|\?\?) http/' || true)"
      MHF="$(echo -n "$MHF" | cut -d' ' -f2-)"
      MIGRATED_HTTP_FILES="$(echo -n "$MHF" | while read -r f; do echo "mkdir -p $(dirname $f); mv tool/$f $(dirname $f)"; done)"
      #MIGRATED_HTTP_FILES="$(for f in $MHF; do echo "mkdir -p $(dirname $f); mv $f $(dirname $f)"; done)" 
      cat <<EOF >> $MIGRATE_FILE


##################
# Migrate box $BOX
cd /ebs/home/$BOX
mkdir pre-symlink-migration
mv tool pre-symlink-migration
if [ -L http ]
then
  rm http
fi
mkdir -p http
ln -s /tools/$TOOLNAME tool
$MIGRATED_HTTP_FILES
cat <<ROLLBACK >> \$UNMIGRATE_FILE
cd /ebs/home/$BOX
rm tool
mv pre-symlink-migration/* .
rmdir pre-symlink-migration
ROLLBACK
EOF
)
    else
      echo ---- Skipping box $BOX -- $TOOLNAME
    fi
  done
