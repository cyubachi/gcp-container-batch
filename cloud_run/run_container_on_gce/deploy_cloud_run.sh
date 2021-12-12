#!/bin/bash -eu

if [[ $# -ne 1 && $# -ne 2 ]]
then
  echo "Invalid arguments."
  echo "usage: ./${0} project_id [region]"
  exit 1
fi

PROJECT_ID=${1}
REGION=${2:-asia-northeast1}

IMAGE="gcp-container-batch"
TAG="latest"

GCR_REPOSITORY_NAME="gcr.io/${PROJECT_ID}/${IMAGE}:${TAG}"

CLOUD_RUN_SERVICE_NAME="run-container-on-gce"

gcloud run deploy ${CLOUD_RUN_SERVICE_NAME} --image ${GCR_REPOSITORY_NAME} --region ${REGION}

echo "Cloud Run successfully deploy to: ${CLOUD_RUN_SERVICE_NAME}"
