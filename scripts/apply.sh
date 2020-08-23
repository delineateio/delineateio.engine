#!/usr/bin/env bash
set -e

###################################################################
# Script Name	: apply.sh
# Description	: Applies a Terraform configuration
# Args          : $1 = The directory where the configure is
#               : $2 = Additional Args for terraform apply
# Author       	: Jonathan Fenwick
# Email         : jonathan.fenwick@delineate.io
###################################################################

# Sets up
FOLDER="${1}"
ARGS="${2}"

# shellcheck source=/dev/null
source ~/.env

cd "${FOLDER}"

# Applies the terraform changes
terraform init -backend-config="bucket=${GOOGLE_PROJECT}-tf"
# shellcheck disable=SC2086
terraform plan -var-file="${DIO_VARS}/${DIO_ENV}.tfvars" $ARGS \
               -lock=true -refresh=true -out="${DIO_VARS}/plan.out"
terraform apply -lock=true -refresh=true -auto-approve "${DIO_VARS}/plan.out"
