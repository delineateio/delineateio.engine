#!/usr/bin/env bash
set -e

###################################################################
# Script Name	: deploy.sh
# Description	: Deploys a specific component to the dev env
# Args          : $1 = Env to use for deployment
# Args          : $2 = Type of the component to deploy
#               : $3 = Name of the component to deploy
# Author       	: Jonathan Fenwick
# Email         : jonathan.fenwick@delineate.io
###################################################################

clear

[[ -z "$1" ]] && { echo "${WARN}Environment not provided${RESET}" ; exit 1; }
[[ -z "$2" ]] && { echo "${WARN}Component type not provided${RESET}" ; exit 1; }
[[ -z "$3" ]] && { echo "${WARN}Component type not provided${RESET}" ; exit 1; }

ENV="${1}"
COMPONENT_TYPE="${2}"
COMPONENT_NAME="${3}"
ROOT=$(git rev-parse --show-toplevel)

# Use the same config as CI/CD
# shellcheck source=/dev/null
source "${ROOT}/.circleci/env/${ENV}.env"
REPO="${GOOGLE_REGISTRY}/${GOOGLE_PROJECT}"

echo
echo "Type:     ${DETAIL}${COMPONENT_TYPE}${RESET}"
echo "Name:     ${DETAIL}${COMPONENT_NAME}${RESET}"
echo "Env:      ${DETAIL}${ENV}${RESET}"
echo "Registry: ${DETAIL}${REPO}${RESET}"
echo

kubectl config use-context "${ENV}"

# Runs skaffold once
cd "${ROOT}/dev/${COMPONENT_TYPE}/${COMPONENT_NAME}"
skaffold run -v warn -p "${ENV}" --default-repo="${REPO}"
