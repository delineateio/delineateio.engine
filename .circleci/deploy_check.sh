#!/usr/bin/env bash
set -e

###################################################################
# Script Name	: deploy_check.sh
# Description	: Cancels the CircleCI job if there is no change
# Args          : $1 = Type of the component to deploy
#               : $2 = Name of the component to deploy
# Author       	: Jonathan Fenwick
# Email         : jonathan.fenwick@delineate.io
###################################################################

TYPE="${1}"
NAME="${2}"
BASE="./.metadata/${TYPE}/"
LOCATION="${BASE}/${NAME}"

echo

# Creates the current dir hash
mkdir -p "${BASE}"
CURRENT=$(find "./dev/${TYPE}/${NAME}" -type f -exec md5sum {} \; | sort -k 2 | md5sum )
echo "$CURRENT" > "${LOCATION}.current"

# Ensures that a file exists - does NOT overwrite if exists!
echo "nullx" > "${LOCATION}.deployed"
gsutil cp -n "${LOCATION}.deployed" "gs://${GOOGLE_PROJECT}-deployments/${TYPE}/${NAME}.deployed"
echo

# Retrieve current deployed file
gsutil cp "gs://${GOOGLE_PROJECT}-deployments/${TYPE}/${NAME}.deployed" "${LOCATION}.deployed"
DEPLOYED="$(cat "${LOCATION}.deployed")"
echo "Current:  ${CURRENT}"
echo "Deployed: ${DEPLOYED}"
echo

# If there is no change then cancels deployment job
if [ "$DEPLOYED" = "$CURRENT" ] ; then
    echo "Deployment halted as not required"
    circleci step halt
    echo
fi
