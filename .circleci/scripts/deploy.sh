#!/usr/bin/env bash
set -e

###################################################################
# Script Name	: deploy.sh
# Description	: Deploys a microservice using Skaffold to the
#               : target cluster
# Author       	: Jonathan Fenwick
# Email         : jonathan.fenwick@delineate.io
###################################################################

# shellcheck source=/dev/null
source ~/.env

COMPONENT_TYPE=${1}
COMPONENT_NAME=${2}

# Installs dependencies
# gcloud components install kubectl skaffold --quiet
# curl -LO https://storage.googleapis.com/container-structure-test/latest/container-structure-test-linux-amd64
# chmod +x container-structure-test-linux-amd64
# mv container-structure-test-linux-amd64 /usr/local/bin/container-structure-test

# Configures gCloud
gcloud container clusters get-credentials app-cluster -z "$GOOGLE_ZONE"

# Applies the deployment using Skaffold
cd "./dev/${COMPONENT_TYPE}/${COMPONENT_NAME}"
skaffold run --skip-tests=true -p "pub" -d "$GOOGLE_REGISTRY/$GOOGLE_PROJECT"
