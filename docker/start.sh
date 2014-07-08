#! /bin/bash
set -x
set -e

cd /opt/custard

date "+%H:%M:%S.%N"
cp -R /data/node_modules .
date "+%H:%M:%S.%N"

npm install --unsafe-perm
source activate

echo Starting mongo.
# Disable the journal, preallocation and syncing,
# since the whole database is discardable.
mongod --dbpath /db --quiet --noprealloc --nojournal --syncdelay=0 &

waitfor() {
	while ! nc -z localhost $1;
	do
		echo waiting for $2 $((i++))
		sleep 0.1
	done
}

waitfor 27017 mongod

# cake dev &
# waitfor 3001 cake-dev

# echo "Sleeping for 20"
# sleep 20
# echo FILES = $(lsof | wc -l)


echo "Starting mocha..."
set +e
mocha test/unit
S=$?
set -e

# TODO(pwaller/drj): Integration tests.

# Kill mongo
kill $(jobs -p)
wait

echo mocha exit status: $S
exit $S
