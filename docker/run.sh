#! /bin/bash

set -x
set -e
set -u

# TODO(pwaller): Working directory = dir of script

docker build -t custard .

# source ../../swops-secret/keys.sh
export CU_DB=mongodb://localhost:27017/testdb
export CU_SESSION_SECRET=foo
export CU_GITHUB_LOGIN=foo
export CU_TOOLS_DIR=/var/tmp/tools
# export CU_BOX_SERVER= # defaults to value from DB.
export CU_SENDGRID_USER=foo@example.com
export CU_SENDGRID_PASS=foo@example.com
export CU_MAILCHIMP_API_KEY=foo
export CU_MAILCHIMP_LIST_ID=foo

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

time docker -D run $ENVS \
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
