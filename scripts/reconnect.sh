#!/usr/bin/env bash
set -e

###################################################################
# Script Name	: reconnect.sh
# Description	: Connect kubectl to the remote 'dev` clsuter',
#               : useful particularly after the cloud environment
#               : has been rebuilt.
# Author       	: Jonathan Fenwick
# Email         : jonathan.fenwick@delineate.io
###################################################################

# Removes previous context
kubectl config delete-context dev

# Retrieves the credentials from GCP
gcloud container clusters get-credentials "${GOOGLE_CLUSTER_NAME}"

# Rename the newly added context
kubectl config rename-context "$(kubectl config current-context)" dev
