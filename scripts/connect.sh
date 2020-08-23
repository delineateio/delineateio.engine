#!/usr/bin/env bash
set -e

###################################################################
# Script Name	: connect.sh
# Description	: Connect kubectl to the remote 'dev` clsuter',
#               : useful particularly after the cloud environment
#               : has been rebuilt.
# Author       	: Jonathan Fenwick
# Email         : jonathan.fenwick@delineate.io
###################################################################

clear
echo
echo "Env:      ${DETAIL}${DIO_ENV}${RESET}"
echo "Cluster:  ${DETAIL}${GOOGLE_CLUSTER_NAME}${RESET}"
echo "Project:  ${DETAIL}${GOOGLE_PROJECT}${RESET}"
echo

# Removes previous context
if [[ $(kubectl config get-contexts --no-headers=true --context='dev') ]]; then
    kubectl config delete-context dev
else
    echo "${WARN}There was no local context called 'dev'${RESET}"
fi

if [[ $(gcloud container clusters list --filter "NAME=${GOOGLE_CLUSTER_NAME}") ]]; then

    # Retrieves the credentials from GCP
    gcloud container clusters get-credentials "${GOOGLE_CLUSTER_NAME}"

    # Rename the newly added context
    kubectl config rename-context "$(kubectl config current-context)" dev

    echo "${COMPLETE}Successful reconnected to the cluster '${GOOGLE_CLUSTER_NAME}'${RESET}"
else
    echo "${WARN}No remote cluster called '${GOOGLE_CLUSTER_NAME}' existed${RESET}"
fi
