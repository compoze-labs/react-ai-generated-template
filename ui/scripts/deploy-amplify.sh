#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

set -euo pipefail

PRODUCT_NAME=$1

# check if environment variable, ENV, is set. If not, print error and exit
if [ -z "${ENV:-}" ]; then
    echo "ENV is not set. Please set ENV to the environment you want to deploy to."
    exit 1
fi

APPNAME="${PRODUCT_NAME}-${ENV}"

npm run build:environment ${ENV}
APPID=$(aws amplify list-apps | jq -r ".apps[] | select(.name==\"${APPNAME}\") | .appId")

BUILD_DIR="${SCRIPT_DIR}/../build"
cd ${BUILD_DIR}
zip build.zip -r .

CREATED_DEPLOYMENT=$(aws amplify create-deployment --app-id ${APPID} --branch-name ${ENV} --no-cli-pager)
JOB_ID=$(echo ${CREATED_DEPLOYMENT} | jq -r .jobId)
UPLOAD_URL=$(echo ${CREATED_DEPLOYMENT} | jq -r .zipUploadUrl)

curl -H "Content-Type: application/zip" ${UPLOAD_URL} --upload-file build.zip

aws amplify start-deployment --app-id ${APPID} --branch-name ${ENV} --job-id ${JOB_ID} --no-cli-pager

cd -

JOB_STATUS=$(aws amplify list-jobs --no-cli-pager --app-id ${APPID} --branch-name ${ENV} | jq ".jobSummaries[] | select(.jobId==\"${JOB_ID}\")" | jq -r .status)

echo "Job status: ${JOB_STATUS}"
RETRY_COUNT=0
MAX_RETRIES=20
until ([ "${JOB_STATUS}" != "RUNNING" ] && [ "${JOB_STATUS}" != "PENDING" ]) || [ "${RETRY_COUNT}" -eq ${MAX_RETRIES} ]
do
    sleep 2
    echo "Job status: ${JOB_STATUS} (attempt: ${RETRY_COUNT})"

    JOB_STATUS=$(aws amplify list-jobs --no-cli-pager --app-id ${APPID} --branch-name ${ENV} | jq ".jobSummaries[] | select(.jobId==\"${JOB_ID}\")" | jq -r .status)
    RETRY_COUNT=$((${RETRY_COUNT}+1))
done