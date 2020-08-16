#!/usr/bin/env bash
set -e

###################################################################
# Script Name	: apply.sh
# Description	: Applies a Terraform configuration
# Args          : $1 = The directory where the configure is
# Author       	: Jonathan Fenwick
# Email         : jonathan.fenwick@delineate.io
###################################################################

# Sets up
# shellcheck source=/dev/null
source ~/.env
cd "${1}"

# Applies the terraform changes
terraform init -backend-config="bucket=${GOOGLE_PROJECT}-tf"
terraform plan -var-file="${DIO_VARS}/${DIO_ENV}.tfvars" \
                              -lock=true -refresh=true -out="${DIO_VARS}/plan.out"
terraform apply -lock=true -refresh=true -auto-approve "${DIO_VARS}/plan.out"
