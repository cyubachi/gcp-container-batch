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
echo ${CREDENTIAL_FILE}

terraform init -backend-config="bucket=${PROJECT_ID}-gcp-container-batch" \
               -backend-config="prefix=gcp-container-batch" \
               -backend-config="credentials=${CREDENTIAL_FILE}" \
               -var credential=${CREDENTIAL_FILE} \
               -var project_id=${PROJECT_ID} \
               -reconfigure
