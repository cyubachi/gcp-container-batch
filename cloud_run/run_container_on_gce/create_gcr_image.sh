#!/bin/bash -eu

if [[ $# -ne 1 ]]
then
  echo "Invalid arguments."
  echo "usage: ./${0} project_id"
  exit 1
fi

PROJECT_ID=${1}

IMAGE="gcp-container-batch"
TAG="latest"
GCR_REPOSITORY_NAME="gcr.io/${PROJECT_ID}/${IMAGE}:${TAG}"

docker buildx build --platform linux/amd64 -t ${IMAGE}:${TAG} .
docker tag ${IMAGE}:${TAG} ${GCR_REPOSITORY_NAME}
docker push ${GCR_REPOSITORY_NAME}
echo "IMAGE successfully pushed to: ${GCR_REPOSITORY_NAME}"
