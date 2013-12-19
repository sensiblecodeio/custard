#! /bin/bash

set -x
set -e
set -u

# TODO(pwaller): Working directory = dir of script

docker build -t custard .

# source ../../swops-secret/keys.sh

ENVS="$(env | grep CU_ | sed 's/^/-e /')"

# Don't quote $ENVS.
cd ..

if ! docker inspect custard-data &> /dev/null
then
  echo "custard-data doesn't exist, populating it"
  docker run \
      -name custard-data \
      -w /data \
      -v /opt/sw$PWD:/data/custard \
      -v /data/node_modules \
      custard \
      /data/custard/docker/populate-node-modules.sh
else
  echo "Reusing existing custard-data"
fi

NAME=tang-run-${TANG_SHA}

docker -D run $ENVS \
    -name $NAME \
    -w /opt/custard \
    -volumes-from custard-data \
    -v /opt/sw$PWD:/opt/custard \
    custard \
    docker/start.sh

S=$(docker wait $NAME)

echo Deleting $(docker rm $NAME)

echo "Docker exited, status: $S"
exit $S
