#!/usr/bin/env bash
set -e

###################################################################
# Script Name	: secure.sh
# Description	: Perfoms security testing on a docker image
# Args          : $1 = Env to use
#               : $2 = Name of the component to deploy
#               : $3 = Type of the component to deploy
# Author       	: Jonathan Fenwick
# Email         : jonathan.fenwick@delineate.io
###################################################################

[[ -z "$1" ]] && { echo "${WARN}Environment not provided${RESET}" ; exit 1; }
[[ -z "$2" ]] && { echo "${WARN}Component type not provided${RESET}" ; exit 1; }
[[ -z "$3" ]] && { echo "${WARN}Component type not provided${RESET}" ; exit 1; }

clear
ENV="${1:-io}" # Defaults to production config
COMPONENT_TYPE="${2}"
COMPONENT_NAME="${3}"
LOCATION="/config"
IMAGE_NAME="${COMPONENT_NAME}:$(git rev-parse --short HEAD)-${ENV}"
ROOT=$(git rev-parse --show-toplevel)
COMPONENT_DIR="${ROOT}/dev/${COMPONENT_TYPE}/${COMPONENT_NAME}"

echo "Type:     ${DETAIL}${COMPONENT_TYPE}${RESET}"
echo "Name:     ${DETAIL}${COMPONENT_NAME}${RESET}"
echo "Env:      ${DETAIL}${ENV}${RESET}"
echo "Config:   ${DETAIL}${LOCATION}${RESET}"
echo "Image:    ${DETAIL}${IMAGE_NAME}${RESET}"
echo

# Builds and runs the container
echo "${START}Image build starting...${RESET}"

MAINTAINER=$(git config user.email)
BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
VCS_REF=$(git rev-parse --short HEAD)

echo "Maintainer:    ${DETAIL}${MAINTAINER}${RESET}"
echo "Build time:    ${DETAIL}${BUILD_DATE}${RESET}"
echo "Git hash:      ${DETAIL}${VCS_REF}${RESET}"

docker build -q \
    --build-arg MAINTAINER="${MAINTAINER}" \
    --build-arg ENV="${ENV}" \
    --build-arg LOCATION="${LOCATION}" \
    --build-arg BUILD_DATE="${BUILD_DATE}" \
    --build-arg VCS_REF="${VCS_REF}" \
    -t "${IMAGE_NAME}" "${COMPONENT_DIR}"

echo "${COMPLETE}Image build completed!${RESET}"
docker inspect "${IMAGE_NAME}" | jq -r '.[0].Config.Labels'
echo

echo "${START}Container structure test starting...${RESET}"
container-structure-test test --image "${IMAGE_NAME}" --config "${COMPONENT_DIR}/structure.yml"
echo "${COMPLETE}Structure tests completed!${RESET}"
echo

# Security scan
# shellcheck source=/dev/null
echo "${START}Snyk image scan starting...${RESET}"
snyk config -q set api="${SNYK_TOKEN}"
snyk test --docker "${IMAGE_NAME}"
echo "${COMPLETE}Snyk image scan completed!${RESET}"
echo

# Performs the Aqua Trivy scan
echo "${START}Trivy image scan starting...${RESET}"
trivy image "${IMAGE_NAME}"
echo "${COMPLETE}Trivy image scan completed!${RESET}"
echo

# Shows the image details
docker images "${IMAGE_NAME}"

echo
