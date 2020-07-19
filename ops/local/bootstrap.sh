#!/usr/bin/env bash
set -e

if [ "$DELINEATEIO_ENV" != "local" ]
then
    echo
    echo "${WARN}The kubctl must be set to 'local' to bootstrap the local cluster!"; exit 1;
fi

# Ensures running in current direct before executing
kubectl apply -f ingress.yml
