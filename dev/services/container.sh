#!/usr/bin/env bash
set -e

clear
ROOT="$(git rev-parse --show-toplevel)"
SERVICE="${1:-customers}"
FOLDER="${ROOT}/dev/services/${SERVICE}"
ENV="prod" # Verifies the production config
LOCATION="/config"
PORT=$(yq r - 'server.port' < "${FOLDER}/config/${ENV}.yml")
IMAGE_NAME="${SERVICE}:$(git rev-parse --short HEAD)-${ENV}"

echo "service:  ${DETAIL}${SERVICE}${RESET}"
echo "env:      ${DETAIL}${ENV}${RESET}"
echo "config:   ${DETAIL}${LOCATION}${RESET}"
echo "port:     ${DETAIL}${PORT}${RESET}"
echo "image:    ${DETAIL}${IMAGE_NAME}${RESET}"
echo

cd "$FOLDER"

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
    -t "${IMAGE_NAME}" .

echo "${COMPLETE}Image build completed!${RESET}"
docker inspect "${IMAGE_NAME}" | jq -r '.[0].Config.Labels'
echo

echo "${START}Container structure test starting...${RESET}"
container-structure-test test --image "${IMAGE_NAME}" --config ./structure.yml
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
