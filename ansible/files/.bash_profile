
source /etc/skel/.bashrc # Maintains colours :)
source /etc/environment # Resets PATH

# Ensure that the $PATH is set correctly
PATH=/snap/bin:$PATH # Ensures snap in the PATH
PATH=$HOME/google-cloud-sdk/bin:$PATH # Adds gcloud to PATH

# Google env variables
export GOOGLE_APPLICATION_CREDENTIALS=~/project/.secrets/gcloud.json
export GCP_PROJECT_ID=io-delineate-cluster
export GCP_REGION=europe-west2
export GCP_ZONE=europe-west2-a
export GCP_CLUSTER_NAME=personal
export GCP_SERVICE_ACCOUNT=development@${GCP_PROJECT_ID}.iam.gserviceaccount.com 
export GCP_REGISTRY=gcr.io

# Sets script wide colours
export START=$(tput setaf 3)
export COMPLETE=$(tput setaf 2)
export DETAIL=$(tput setaf 6)
export RESET=$(tput sgr0)

# Starts SSH sessions in the project folder and enables scripts
cd ~/project

# TODO: This is messy!  Reafactor into Ansible
chmod +x $(find . -type f -name "*.sh")