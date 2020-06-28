#!/usr/bin/env bash
set -e

STACK_TAG="$(git rev-parse --short HEAD)"
export STACK_TAG

STACK_MAINTAINER="$(git config user.email)"
export STACK_MAINTAINER

STACK_BUILD_DATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
export STACK_BUILD_DATE

STACK_VCS_REF="${STACK_TAG}"
export STACK_VCS_REF

# Ensures the stack is down
docker-compose down --remove-orphans

# Stands up the stack
docker-compose up -d --quiet-pull
