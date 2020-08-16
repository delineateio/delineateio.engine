#!/usr/bin/env bash
set -e

###################################################################
# Script Name	: variables.sh
# Description	: Updates the variables.tf file for each component
# Author       	: Jonathan Fenwick
# Email         : jonathan.fenwick@delineate.io
###################################################################

ROOT=$(git rev-parse --show-toplevel)
VARIABLES="${ROOT}/.circleci/tf/variables.tf"

cd "${ROOT}/ops/cloud"
for DIR in */ ; do
    cp "${VARIABLES}" "${ROOT}/ops/cloud/${DIR}variables.tf"
done

cd "${ROOT}/dev/services"
for DIR in */ ; do
    cp "${VARIABLES}" "${ROOT}/dev/services/${DIR}tf/variables.tf"
done
