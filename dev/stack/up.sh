#!/usr/bin/env bash
set -e

export STACK_ENV=stack
export STACK_LOCATION=/config
# shellcheck disable=SC2155
export STACK_TAG="$(git rev-parse --short HEAD)"
# shellcheck disable=SC2155
export STACK_MAINTAINER="$(git config user.email)"
# shellcheck disable=SC2155
export STACK_BUILD_DATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
export STACK_VCS_REF="${STACK_TAG}"

# Ensures the stack is down
docker-compose down --remove-orphans

# Stands up the stack
docker-compose up -d --quiet-pull
