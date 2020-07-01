#!/usr/bin/env bash
set -e

PROJECT="${1:-io-delineate-engine-staging}"
REGION="${2:-europe-west2}"
USER="infrastructure"
SERVICE_ACCOUNT="${USER}@${PROJECT}.iam.gserviceaccount.com"

# Changes config settings
gcloud config set project "${PROJECT}"
gcloud config set compute/region "${REGION}"

# Creates the state bucket from terraform
echo "${START}Creating Terraform state bucket...${RESET}"
gsutil mb -c standard -b on -l "${REGION}" "gs://${PROJECT}-tf/"
echo "${COMPLETE}Terraform state bucket created${RESET}"
echo

# Create the service account
echo "${START}Creating '${USER}' service account...${RESET}"
gcloud iam service-accounts create ${USER} \
    --description="This service account is used to provision infrastructure"
echo "${COMPLETE}Service account created${RESET}"
echo

# Add the roles to the service account
echo "${START}Adding roles...${RESET}"
while read -r ROLE; do
    gcloud projects add-iam-policy-binding "${PROJECT}" \
        --member="serviceAccount:${SERVICE_ACCOUNT}" --role="${ROLE}"
        echo "Added to '${ROLE}'"
done <roles.txt
echo "${COMPLETE}Roles added${RESET}"
echo

# Enable the required APIs
echo "${START}Enabling API services...${RESET}"
while read -r SERVICE; do
    gcloud services enable "${SERVICE}"
    echo "'${SERVICE}' enabled"
done <services.txt
echo "${COMPLETE}Services enabled${RESET}"
echo

# Creates the key
gcloud iam service-accounts keys create /tmp/key.json \
  --iam-account "${SERVICE_ACCOUNT}"

# displays the key on the screen
cat /tmp/key.json
