#! /bin/bash

set -x
set -e
set -u

# TODO(pwaller): Working directory = dir of script

docker build -t custard .

# source ../../swops-secret/keys.sh
export CU_DB=mongodb://localhost:27017/cu-test
export CU_BOX_SERVER=scraperiwiki.example.com
export CU_SESSION_SECRET=foo
export CU_TOOLS_DIR=/var/tmp/tools
# export CU_BOX_SERVER= # defaults to value from DB.
export CU_SENDGRID_USER=foo@example.com
export CU_SENDGRID_PASS=foo@example.com
export CU_MAILCHIMP_API_KEY=foo
export CU_MAILCHIMP_LIST_ID=foo

# When using this variable, don't write "$ENVS", write $ENVS.
# Word splitting is intentional.
ENVS="$(env | grep CU_ | sed 's/^/-e /')"

if ! docker inspect custard-data &> /dev/null
then

  echo "custard-data doesn't exist, populating it"

  cp ../package.json ./custard-data-image/package.json
  sed -i .bak '/cake build/d' ./custard-data-image/package.json

  docker build -t custard-data-image custard-data-image

  docker run \
      --name custard-data \
      -w /data \
      -v /data/node_modules \
      custard-data-image \
      npm install --unsafe-perm
else
  echo "Reusing existing custard-data"
fi

cd ..

echo LS:
ls -l /tang/repo/
echo PWD:
pwd
echo LS PWD:
ls -l $PWD

NAME=tang-run-${TANG_SHA}

# Note: This will all change when we do DIND
# (docker in docker). Note that the volume mounts only work for DOD.
time docker -D run -t $ENVS \
    --name $NAME \
    -w /opt/custard \
    --volumes-from custard-data \
    -v /var/lib$PWD:/opt/custard \
    -v /db:/db \
    custard \
    docker/start.sh

S=$(docker wait $NAME)

echo Deleting $(docker rm $NAME)

echo "Docker exited, status: $S"
exit $S
