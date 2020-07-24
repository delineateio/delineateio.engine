#!/usr/bin/env bash
set -e


###################################################################
# Script Name	: bootstrap.sh
# Description	: Bootstraps a new environment for GCP & Cloudflare
# Args          : $1 delineate.io environment
#               : $2 GCP Project ID
#               : $3 GCP Region
#               : $4 Cloudflare Domain
#               : $5 Cloudflare Token
#               : $6 Cloudflare Zone
# Author       	: Jonathan Fenwick
# Email         : jonathan.fenwick@delineate.io
###################################################################


# bootstrap.sh
#   dev
#   io-delineate-engine-dev
#   europe-west2
#   delineate.dev
#   abc-token
#   abc-zone

echo
[[ -z "$1" ]] && { echo "${WARN}Environment not provided${RESET}" ; exit 1; }
[[ -z "$2" ]] && { echo "${WARN}GCP Project not provided${RESET}" ; exit 1; }
[[ -z "$3" ]] && { echo "${WARN}GCP Region not provided${RESET}" ; exit 1; }
[[ -z "$4" ]] && { echo "${WARN}Cloudflare Domain not provided${RESET}" ; exit 1; }
[[ -z "$5" ]] && { echo "${WARN}Cloudflare Token not provided${RESET}" ; exit 1; }
[[ -z "$6" ]] && { echo "${WARN}Cloudflare Zone not provided${RESET}" ; exit 1; }

# Sets variables
ENV="${1}"
PROJECT="${2}"
REGION="${3}"
CLOUDFLARE_DOMAIN="${4}"
CLOUDFLARE_TOKEN="${5}"
CLOUDFLARE_ZONE="${6}"
USER="infrastructure"
SERVICE_ACCOUNT="${USER}@${PROJECT}.iam.gserviceaccount.com"
KEY_FILE="$HOME/.gcloud/delineateio.engine/$ENV/key.json"

# Changes config settings
gcloud config set project "${PROJECT}"
gcloud config set compute/region "${REGION}"

# ---------------------------------------------------------------------

# Creates the state bucket from terraform
echo "${START}Creating Terraform state bucket...${RESET}"
gsutil mb -c standard -b on -l "${REGION}" "gs://${PROJECT}-tf/"
echo "${COMPLETE}Terraform state bucket created${RESET}"
echo

# ---------------------------------------------------------------------

# Creates the bucket to track deployments
echo "${START}Creating Deployments bucket...${RESET}"
gsutil mb -c standard -b on -l "${REGION}" "gs://${PROJECT}-deployments/"
echo "${COMPLETE}Deployments bucket created${RESET}"
echo

# ---------------------------------------------------------------------

# Create the service account
echo "${START}Creating '${USER}' service account...${RESET}"
gcloud iam service-accounts create ${USER} \
    --description="This service account is used to provision infrastructure"
echo "${COMPLETE}Service account created${RESET}"
echo

# ---------------------------------------------------------------------

# Add the roles to the service account
echo "${START}Adding roles...${RESET}"
while read -r ROLE; do
    gcloud projects add-iam-policy-binding "${PROJECT}" \
        --member="serviceAccount:${SERVICE_ACCOUNT}" --role="${ROLE}"
        echo "Added to '${ROLE}'"
done <roles.txt
echo "${COMPLETE}Roles added${RESET}"
echo

# ---------------------------------------------------------------------

# Enable the required APIs
echo "${START}Enabling API services...${RESET}"
while read -r SERVICE; do
    gcloud services enable "${SERVICE}"
    echo "'${SERVICE}' enabled"
done <services.txt
echo "${COMPLETE}Services enabled${RESET}"
echo

# ---------------------------------------------------------------------

echo "${START}Removing default fw rules and network...${RESET}"
# Deletes the default firewall rules and network
gcloud compute firewall-rules delete default-allow-icmp \
                                     default-allow-internal \
                                     default-allow-rdp \
                                     default-allow-ssh

gcloud compute networks delete default
echo "${COMPLETE}Default network removed${RESET}"

# ---------------------------------------------------------------------

echo "${START}Creating Cloudflare secrets...${RESET}"

echo "${CLOUDFLARE_DOMAIN}" | gcloud secrets create "cloudflare-domain" \
                            --replication-policy "automatic" \
                            --data-file -

echo "${CLOUDFLARE_TOKEN}" | gcloud secrets create "cloudflare-token" \
                            --replication-policy "automatic" \
                            --data-file -

echo "${CLOUDFLARE_ZONE}" | gcloud secrets create "cloudflare-zone" \
                            --replication-policy "automatic" \
                            --data-file -

echo "${START}Cloudflare secrets created${RESET}"

# ---------------------------------------------------------------------

# displays the key on the screen
echo "${START}Creating service account key...${RESET}"

# Creates the key
gcloud iam service-accounts keys create "$KEY_FILE" \
                                --iam-account "${SERVICE_ACCOUNT}"

echo "${START}Creating service account token...${RESET}"

# ---------------------------------------------------------------------
