#!/bin/bash -eu

cd $(dirname ${0})

if [[ $# -ne 1 && $# -ne 2 ]]
then
  echo "Invalid arguments."
  echo "usage: ./${0} project_id [region]"
  exit 1
fi

PROJECT_ID=${1}
REGION=${2:-asia-northeast1}
CREDENTIAL_FILE=$(ls -1 credentials/*.json)
PROJECT_NUMBER=$(gcloud projects list --format="table(project_id, project_number)" | tail -1 | awk '{print $2}')
terraform plan -var credential=${CREDENTIAL_FILE} \
               -var project_id=${PROJECT_ID} \
               -var region=${REGION} \
               -var project_number=${PROJECT_NUMBER} \
               -input=false \
               -out=tfplan
