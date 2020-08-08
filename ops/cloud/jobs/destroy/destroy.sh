#!/usr/bin/env bash
set -e

NAME=destroy

# remove, build & run
docker rm $NAME -f || true
docker build -t $NAME .
docker run -d --name $NAME -v ~/.gcloud/delineateio/platform/dev:/.gcloud \
                           -p 8080:8080 \
                           -e DIO_ENV=dev \
                           -e DIO_REPO_URL=https://github.com/delineateio/platform.git \
                           -e DIO_REPO_ROOT=/platform \
                           -e GOOGLE_PROJECT="io-delineate-engine-dev" \
                           -e GOOGLE_APPLICATION_CREDENTIALS=/.gcloud/key.json $NAME

# Displays dstroy output
http POST :8080/http body='{"components"=["ingress", "cluster"]}'
docker logs $NAME

# Runs commands inside container
docker exec -it $NAME terraform version
