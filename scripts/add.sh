#!/usr/bin/env bash
set -e

###################################################################
# Script Name	: add.sh
# Description	: Add a deployment entry into the bucket
# Args          : $1 = Type of the component to deploy
#               : $2 = Name of the component to deploy
# Author       	: Jonathan Fenwick
# Email         : jonathan.fenwick@delineate.io
###################################################################

TYPE="${1}"
NAME="${2}"

# shellcheck source=/dev/null
source ~/.env

# Retrieve current
gsutil cp "/tmp/${NAME}.current" "gs://${GOOGLE_PROJECT}-deployments/${TYPE}/${NAME}.deployed"
