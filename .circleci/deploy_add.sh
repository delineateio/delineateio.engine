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
LOCATION="./.metadata/${TYPE}/${NAME}"

# Retrieve current
gsutil cp "${LOCATION}.current" "gs://${GOOGLE_PROJECT}-deployments/${TYPE}/${NAME}.deployed"
