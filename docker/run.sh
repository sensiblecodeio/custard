#! /bin/bash

# TODO(pwaller): Working directory = dir of script

docker build -t custard .

source ../../swops-secret/keys.sh

ENVS="$(env | grep CU_ | sed 's/^/-e /')"
# Don't quote $ENVS.
SCRIPT='
cd /opt/custard
npm install --unsafe-perm
source activate
echo Starting redis.
redis-server &> /dev/null &
echo Starting mongo
mkdir -p /data/db
mongod &
cake dev
'
docker run -p 3001:3001 $ENVS -v $(pwd)/..:/opt/custard -t -i custard bash -c "$SCRIPT"
