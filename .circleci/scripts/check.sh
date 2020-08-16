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

# shellcheck source=/dev/null
source ~/.env

# Creates the current dir hash
CURRENT=$(find "./dev/${TYPE}/${NAME}" -type f -exec md5sum {} \; | sort -k 2 | md5sum )
echo "$CURRENT" > "/tmp/${NAME}.current"

# Ensures that a file exists - does NOT overwrite if exists!
echo "nullx" > "/tmp/${NAME}.deployed"
gsutil cp -n "/tmp/${NAME}.deployed" "gs://${GOOGLE_PROJECT}-deployments/${TYPE}/${NAME}.deployed"
echo

# Retrieve current deployed file
gsutil cp "gs://${GOOGLE_PROJECT}-deployments/${TYPE}/${NAME}.deployed" "/tmp/${NAME}.deployed"
DEPLOYED="$(cat "/tmp/${NAME}.deployed")"
echo "Current:  ${CURRENT}"
echo "Deployed: ${DEPLOYED}"
echo

# If there is no change then cancels deployment job
if [ "$DEPLOYED" = "$CURRENT" ] ; then
    echo "Deployment halted as not required"
    circleci step halt
    echo
fi
