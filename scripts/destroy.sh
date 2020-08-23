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

# Adds
function destroy() {

    ENV="${1}"
    COMPONENT="${2}"
    ARGS="${3}"
    ROOT=$(git rev-parse --show-toplevel)

    # shellcheck source=/dev/null
    source "${ROOT}/.circleci/env/${ENV}.env"

    # shellcheck disable=SC2034
    GOOGLE_CREDENTIALS=$(cat "${HOME}/.gcloud/delineateio/platform/${ENV}/key.json")

    # Applies the terraform changes
    cd "${ROOT}/ops/cloud/${COMPONENT}"
    rm -rf .terraform

    echo
    echo "Env:       ${DETAIL}${ENV}${RESET}"
    echo "Component: ${DETAIL}${COMPONENT}${RESET}"
    echo "Project:   ${DETAIL}${GOOGLE_PROJECT}${RESET}"

    terraform init -backend-config="bucket=${GOOGLE_PROJECT}-tf"

    # shellcheck disable=SC2086
    terraform destroy -var-file="${DIO_VARS}/${DIO_ENV}.tfvars" ${ARGS} -lock=true -refresh=true -auto-approve

    # Cleans up
    rm -rf .terraform
}

clear

# Dev environment
destroy "dev" "ingress"
destroy "dev" "database" "-var service_name=customers"
destroy "dev" "cluster"

# Dev environment
destroy "pub" "ingress"
destroy "dev" "database" "-var service_name=customers"
destroy "pub" "cluster"
