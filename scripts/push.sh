#!/usr/bin/env bash
set -e

###################################################################
# Script Name	: push.sh
# Description	: Deploys a microservice using Skaffold to the
#               : the target cluster
# Author       	: Jonathan Fenwick
# Email         : jonathan.fenwick@delineate.io
###################################################################

# Load env
# shellcheck source=/dev/null
source ~/.env

# Gets the context dir
CONTEXT="${1}"

# Authorise Docker
gcloud components install docker-credential-gcr -q
gcloud auth configure-docker -q
docker-credential-gcr configure-docker

# Build and push
IMAGE="${GOOGLE_REGISTRY}/${GOOGLE_PROJECT}/${2}:latest"
docker build -t "${IMAGE}" "${CONTEXT}"
docker push "${IMAGE}"
