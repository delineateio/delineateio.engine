#!/usr/bin/env bash
set -e

###################################################################
# Script Name	: destroy.sh
# Description	: Destroys the infrastructure for `dev` and `pub`
# Args          : $1 = Env to use
# Author       	: Jonathan Fenwick
# Email         : jonathan.fenwick@delineate.io
###################################################################

[[ -z "$1" ]] && { echo "${WARN}Environment not provided${RESET}" ; exit 1; }

BASE_ENV="${1}"

# Adds
function destroy() {

    ENV="${1}"
    COMPONENT="${2}"
    ARGS="${3}"
    ARGS_SIZE="${#ARGS}"
    ROOT=$(git rev-parse --show-toplevel)

    # shellcheck source=/dev/null
    source "${ROOT}/env/${ENV}.env"

    # shellcheck disable=SC2034
    GOOGLE_CREDENTIALS=$(cat "${HOME}/.gcloud/${ENV}/key.json")

    # Applies the terraform changes
    cd "${ROOT}/ops/cloud/${COMPONENT}"
    rm -rf .terraform

    echo
    echo "Env:       ${DETAIL}${ENV}${RESET}"
    echo "Component: ${DETAIL}${COMPONENT}${RESET}"
    echo "Project:   ${DETAIL}${GOOGLE_PROJECT}${RESET}"

    if [ "$ARGS_SIZE" -gt 0 ]; then
        echo
    fi

    terraform init -backend-config="bucket=${GOOGLE_PROJECT}-tf"

    # shellcheck disable=SC2086
    terraform destroy -var-file="${DIO_VARS}/${DIO_ENV}.tfvars" ${ARGS} -lock=true -refresh=true -auto-approve

    # Cleans up
    rm -rf .terraform
}

clear

# Environment
destroy "${BASE_ENV}" "ingress"
destroy "${BASE_ENV}" "database" "-var service_name=customers"
destroy "${BASE_ENV}" "cluster"
