#!/usr/bin/env bash
set -e

###################################################################
# Script Name	: branch.sh
# Description	: Selects the env variables for the branch that is
#               : has been committed to git
# Author       	: Jonathan Fenwick
# Email         : jonathan.fenwick@delineate.io
###################################################################

BRANCH="$CIRCLE_BRANCH"
ROOT=$(git rev-parse --show-toplevel)

# Sets defaults
cp "${ROOT}/.circleci/env/dev.env" ~/.env

# TODO: For now this replays on top
# of the dev env for cost purposes
if [ "$BRANCH" == "master" ]
then
    cp "${ROOT}/.circleci/env/pub.env" ~/.env
fi

# shellcheck source=/dev/null
source ~/.env

# Show values for debugging CircleCI
cat ~/.env
