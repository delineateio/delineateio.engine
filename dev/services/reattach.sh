#!/usr/bin/env bash
set -e

# Unsets current dev context
kubectl config unset contexts.dev

# Reconfigs dev cluster
gcloud container clusters get-credentials "${GCP_CLUSTER_NAME}"
kubectl config rename-context "$(kubectl config current-context)" dev
