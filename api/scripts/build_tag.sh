#!/usr/bin/env bash

set -euo pipefail

APP_NAME=$1
TAG=$2


echo "installing dependencies"
npm i
echo "building ${APP_NAME}:${TAG}"
docker build . -t "${APP_NAME}:${TAG}"
