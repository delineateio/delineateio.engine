#!/usr/bin/env bash
set -e

echo
[[ -z "$1" ]] && { echo "${WARN}GCP Project not provided${RESET}" ; exit 1; }
[[ -z "$2" ]] && { echo "${WARN}GCP Region not provided${RESET}" ; exit 1; }
[[ -z "$3" ]] && { echo "${WARN}Cloudflare Domain not provided${RESET}" ; exit 1; }
[[ -z "$4" ]] && { echo "${WARN}Tls cert & key directory not provided${RESET}" ; exit 1; }

# TODO: Further validation of the parameters
# Does the GCP project exist?
# Is the GCP region valid?
# Validate domain name?
# Both cert and key file provided and correct format?

PROJECT="${1}"
REGION="${2}"
DOMAIN="${3}"
CERT_DIR="${4}"

USER="infrastructure"
SERVICE_ACCOUNT="${USER}@${PROJECT}.iam.gserviceaccount.com"
SECRET_PREFIX="${DOMAIN/"."/"-"}"

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

# Deletes the default firewall rules and network
gcloud compute firewall-rules delete default-allow-icmp \
                                     default-allow-internal \
                                     default-allow-rdp \
                                     default-allow-ssh

gcloud compute networks delete default

# Creates the key
gcloud iam service-accounts keys create /tmp/key.json \
  --iam-account "${SERVICE_ACCOUNT}"

gcloud beta secrets create "${SECRET_PREFIX}-key" \
    --replication-policy "automatic" \
    --data-file "$CERT_DIR/$DOMAIN.key.pem"

gcloud beta secrets create "${SECRET_PREFIX}-cert" \
    --replication-policy "automatic" \
    --data-file "$CERT_DIR/$DOMAIN.cert.pem"

# displays the key on the screen
cat /tmp/key.json
