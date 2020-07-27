#!/usr/bin/env bash
set -e

###################################################################
# Script Name	: dev.sh
# Description	: Deploys a specific component to the dev env
# Args          : $1 = Type of the component to deploy
#               : $2 = Name of the component to deploy
# Author       	: Jonathan Fenwick
# Email         : jonathan.fenwick@delineate.io
###################################################################

# Validates inputs
[[ -z "$1" ]] && { echo "${WARN}Component type not provided${RESET}" ; exit 1; }
[[ -z "$2" ]] && { echo "${WARN}Component name not provided${RESET}" ; exit 1; }

clear
COMPONENT_TYPE="${1}"
COMPONENT_NAME="${2}"
ROOT="$(git rev-parse --show-toplevel)"
PROFILE="dev"
REPO="${GOOGLE_REGISTRY}/${GOOGLE_PROJECT}"

echo
echo "Type:     ${DETAIL}${COMPONENT_TYPE}${RESET}"
echo "Name:     ${DETAIL}${COMPONENT_NAME}${RESET}"
echo "Env:      ${DETAIL}${PROFILE}${RESET}"
echo "Registry: ${DETAIL}${REPO}${RESET}"
echo

kubectl config use-context "${PROFILE}"

# Runs skaffold once
cd "${ROOT}/dev/${COMPONENT_TYPE}/${COMPONENT_NAME}"
skaffold run -v warn -p "${PROFILE}" --default-repo="${REPO}"
